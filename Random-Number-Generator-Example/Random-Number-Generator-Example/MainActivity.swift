import Foundation
import EdgeCore
import EdgeEngine
import Alamofire

final class MainActivity: NSObject {
    
    override init() {
        super.init()
        
        Task {
            // Starting mimOE Runtime.
            guard case .success = await self.start() else {
                return
            }
            
            // Generating Access Token.
            guard case let .success(accessToken) = await self.accessToken() else {
                return
            }

            // Deploying Random Number edge microservice.
            guard case .success = await self.deployMicroservice(accessToken: accessToken) else {
                return
            }
        }
    }

    // Buggy synchronous method that always returns the same number
    func generateRandomNumber() -> Int {
        return 60
    }
    
    // mimik Client Library instance
    let edgeClient: EdgeClient = {
        return EdgeClient()
    }()
    
    // Asynchronous method returning the success or failure of edgeEngine Runtime startup
    func start() async -> Result<Void, NSError> {
        
        // Loading the content of the Developer-mimOE-License file as a String
        guard let file = Bundle.main.path(forResource: "Developer-mimOE-License", ofType: nil), let license = try? String(contentsOfFile: file).replacingOccurrences(of: "\n", with: "") else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Developer-mimOE-License Error", code: 500))
        }
        
        // License parameter is the only parameter required for mimOE Runtime startup. There are other optional parameters also available.
        let params = EdgeClient.StartupParameters(license: license)
        
        // Using the mimik Client Library to start the mimOE Runtime
        switch await self.edgeClient.startEdgeEngine(parameters: params) {
        case .success:
            print(#function, #line, "Success")
            return .success(())
        case .failure(let error):
            print(#function, #line, "Error", error.localizedDescription)
            return .failure(error)
        }
    }

    // Asynchronous method returning the success or failure of generating an Access Token
    func accessToken() async -> Result<String, NSError> {
        
        // Loading the content of Developer-ID-Token file as a String
        guard let developerIdTokenFile = Bundle.main.path(forResource: "Developer-ID-Token", ofType: nil), let developerIdToken = try? String(contentsOfFile: developerIdTokenFile).replacingOccurrences(of: "\n", with: "") else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Developer-ID-Token Error", code: 500))
        }
        
        // Calling mimik Client Library to generate the edgeEngine Access Token. Passing-in the Developer ID Token as a parameter.
        switch await self.edgeClient.authorizeDeveloper(developerIdToken: developerIdToken) {
        case .success(let authorization):
            
            guard let accessToken = authorization.token?.accessToken else {
                print(#function, #line, "Error")
                return .failure(NSError(domain: "Access Token Error", code: 500))
            }
            
            print(#function, #line, "Success", accessToken)
            return .success(accessToken)
            
        case .failure(let error):
            print(#function, #line, "Error", error.localizedDescription)
            return .failure(error)
        }
    }

    // Asynchronous method returning the success or failure of deploying an edge microservice
    func deployMicroservice(accessToken: String) async -> Result<EdgeClient.Microservice, NSError> {

        // Establishing application's bundle reference to the randomnumber_v1.tar file
        guard let imageTarPath = Bundle.main.path(forResource: "randomnumber_v1", ofType: "tar") else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Tar file Error", code: 500))
        }
        
        // Setting up the edge microservice deployment configuration
        let config = EdgeClient.Microservice.Config(imageName: "randomnumber-v1", containerName: "randomnumber-v1", basePath: "/randomnumber/v1", envVariables: [:])
        
        // Using the mimik Client Library method to deploy the edge microservice
        switch await self.edgeClient.deployMicroservice(edgeEngineAccessToken: accessToken, config: config, imageTarPath: imageTarPath) {
        case .success(let microservice):
            print(#function, #line, "Success", microservice)
            return .success(microservice)
        case .failure(let error):
            print(#function, #line, "Error", error.localizedDescription)
            return .failure(error)
        }
    }

    // New asynchronous method returning a randomly generated number
    func generateRandomNumberNew() async -> Result<Int, NSError> {
        
        // Getting the Access Token ready
        guard case let .success(edgeEngineAccessToken) = await self.accessToken() else {
            // Returning zero. This is a failed scenario.
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Access Token Error", code: 500))
        }
        
        // Getting a reference to the deployed edge microservice
        guard case let .success(microservice) = await
                self.edgeClient.microservice(containerName: "randomnumber-v1", edgeEngineAccessToken: edgeEngineAccessToken) else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Deployment Error", code: 500))
        } // 15
        
        // Establishing the edge microservice endpoint full path URL
        guard let endpointUrlComponents = microservice.fullPathUrl(withEndpoint: "/randomNumber"), let endpointUrl = endpointUrlComponents.url else {
            // Returning zero. This is a failed scenario.
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Microservice Error", code: 500))
        }
        
        // Calling the edge microservice endpoint using the Alamofire networking library.
        let dataTask = AF.request(endpointUrl).serializingDecodable(Int.self)
        guard let value = try? await dataTask.value else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Decoding Error", code: 500))
        }
        
        print(#function, #line, "Success", value)
        return .success(value)
    }
}
