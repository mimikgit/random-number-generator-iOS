import Foundation
import MIMIKEdgeClientCore
import MIMIKEdgeClientEngine
import Alamofire

final class MainActivity: NSObject {
    
    override init() {
        super.init()
        
        Task {
            // Start edgeEngine Runtime. Fail for an error.
            guard await self.startEdgeEngine() else {
                fatalError(#function)
            }
            
            // Generate edgeEngine Access Token. Fail for an error.
            guard let edgeEngineAccessToken = await self.accessToken() else {
                fatalError(#function)
            }

            // Deploy Random Number edge microservice. Fail for an error.
            guard let microservice = await self.deployRandomNumberMicroservice(edgeEngineAccessToken: edgeEngineAccessToken) else {
                fatalError(#function)
            }
        }
    }
    
    // Synchronous method that was supposed to return a randomly generated number
    func generateRandomNumber() -> Int {
        return 60
    }
    
    // mimik Client Library Core component instance
    let edgeClient: MIMIKEdgeClient = {
        return MIMIKEdgeClient()
    }()

    // mimik Client Library Engine component instance
    let edgeEngine: MIMIKEdgeClientEdgeEngine = {
        guard let mimikEdgeEngine = MIMIKEdgeClientEdgeEngine() else {
            fatalError(#function)
        }
        return mimikEdgeEngine
    }()
    
    // Starting the edgeEngine Runtime
    func startEdgeEngine() async -> Bool {
        
        // Loading the content of edgeEngine-License file as a String
        guard let file = Bundle.main.path(forResource: "edgeEngine-License", ofType: nil), let license = try? String(contentsOfFile: file).replacingOccurrences(of: "\n", with: "") else {
            print("Error")
            return false
        }
        
        // License parameter is the only parameter required for edgeEngine Runtime startup. Other parameters are not shown by default
        let params = MIMIKStartupParameters.init(license: license)
        
        // Using the mimik Client Library Engine component's method to start the edgeEngine Runtime
        switch await self.edgeEngine.startEdgeEngine(startupParameters: params) {
        case .success:
            return true
        case .failure(let error):
            print("Error", error.localizedDescription)
            return false
        }
    }

    // Generates Access Token that's necessary to work with edge microservices
    func accessToken() async -> String? {
        
        // Loading the content of Developer-ID-Token file as a String
        guard let developerIdTokenFile = Bundle.main.path(forResource: "Developer-ID-Token", ofType: nil), let developerIdToken = try? String(contentsOfFile: developerIdTokenFile).replacingOccurrences(of: "\n", with: "") else {
            print("Error")
            return nil
        }
        
        // Using the mimik Client Library method to get the edgeEngine Access Token. Passing in the Developer ID Token as a parameter
        switch await self.edgeClient.authenticateDeveloperAccess(developerIdToken: developerIdToken) {
        case .success(let authorization):
                            
            guard let accessToken = authorization.userAccessToken() else {
                print("Error")
                return nil
            }
            
            print("Success. Access Token:", accessToken)
            
            // Returning edgeEngine Access Token
            return accessToken
        case .failure(let error):
            print("Error", error.localizedDescription)
            return nil
        }
    }

    // Deploys and returns an edge microservice under the edgeEngine Runtime. Requires Access Token
    func deployRandomNumberMicroservice(edgeEngineAccessToken: String) async -> MIMIKMicroservice? {

        // Establishing application bundle reference to the randomnumber_v1.tar file
        guard let imageTarPath = Bundle.main.path(forResource: "randomnumber_v1", ofType: "tar") else {
            return nil
        }
        
        // Setting up the deployment configuration object with hardcoded values for simplicity
        let config = MIMIKMicroserviceConfig.init(imageName: "randomnumber-v1", containerName: "randomnumber-v1", baseApiPath: "/randomnumber/v1", envVariables: [:])
        
        // Using the mimik Client Library method to deploy the edge microservice
        switch await self.edgeClient.deployMicroservice(edgeEngineAccessToken: edgeEngineAccessToken, config: config, imageTarPath: imageTarPath) {
        case .success(let microservice):
            print("Success")
            return microservice
        case .failure(let error):
            print("Error", error.localizedDescription)
            return nil
        }
    }

    // Returns a randomly generated number from the edge microservice
    func generateRandomNumber() async -> Int {
        
        // Getting the Access Token ready
        guard let edgeEngineAccessToken = await self.accessToken() else {
            // Returning zero. This is a failed scenario.
            print("Error")
            return 0
        }
        
        // Getting a reference to the deployed edge microservice
        guard case let .success(microservices) = await self.edgeClient.deployedMicroservices(edgeEngineAccessToken: edgeEngineAccessToken), let microservice = microservices.first else {
            // Returning zero. This is a failed scenario.
            print("Error")
            return 0
        }
        
        // Establishing the edge microservice endpoint URL
        guard let endpointUrlComponents = microservice.urlComponents(withEndpoint: "/randomNumber"), let endpointUrl = endpointUrlComponents.url else {
            // Returning zero. This is a failed scenario.
            print("Error")
            return 0
        }
        
        // Alamofire request call to the endpoint's URL
        let dataTask = AF.request(endpointUrl).serializingDecodable(Int.self)
        guard let value = try? await dataTask.value else {
            print("Error")
            return 0
        }
        
        print("Success. Random number:", value)
        // Returning the received random number
        return value
    }
}
