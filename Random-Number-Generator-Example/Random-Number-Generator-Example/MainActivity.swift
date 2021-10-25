import Foundation
import MIMIKEdgeMobileClient
import Alamofire

final class MainActivity: NSObject {
    
    override init() {
        super.init()
        
        // Async/await task wrapper
        Task {
        
            // Check for the success of the startEdgeEngine asynchronous task. Fail fatally for an error.
            guard await self.startEdgeEngine() else {
                fatalError(#function)
            }
            
            // Check for a success of the startEdgeEngine asynchronous task. Fail fatally for an error.
            // Establish the Access Token as `let edgeEngineAccessToken`
            guard let edgeEngineAccessToken = await self.authorizeEdgeEngine() else {
                fatalError(#function)
            }

            // Check for a success of the startEdgeEngine asynchronous task. Fail fatally for an error.
            // Establish the deployed edge microservice reference as  `let microservice`
            guard let microservice = await self.deployRandomNumberMicroservice(edgeEngineAccessToken: edgeEngineAccessToken) else {
                fatalError(#function)
            }
            
            // Assign the deployed edge microservice reference to the `self.microservice` instance variable
            self.microservice = microservice
        }
    }
    
    // Synchronous method that was supposed to return a randomly generated number
    func generateRandomNumber() -> Int {
        return 60
    }
    
    // A lazy instance variable of the mimik Client Library
    // Will be initialized on first access only.
    // Will remain initialized for all subsequent calls.
    lazy var mimikClientLibrary: MIMIKEdgeMobileClient = {
        let library = MIMIKEdgeMobileClient.init(license: nil)
        
        guard let checkedLibrary = library else {
            fatalError()
        }
                
        return checkedLibrary
    }()
    
    // Instance variable optional, a reference to the deployed edge microservice
    var microservice: MIMIKMicroservice?

    // Asynchronous method starting the edgeEngine Runtime
    // and returning a Bool indicating the result.
    func startEdgeEngine() async -> Bool {
        
        // Closure wrapper for async/await
        return await withCheckedContinuation { continuation in
            
            // Starting the edgeEngine Runtime with default startup parameters
            self.mimikClientLibrary.startEdgeEngine(startupParameters: nil) { result in
                
                // Resuming the closure by returning the result value
                continuation.resume(returning: (result))
            }
        }
    }

    // Asynchronous method returning the Access Token that's necessary to work
    // with the edge microservice running under the edgeEngine Runtime
    func authorizeEdgeEngine() async -> String? {
        
        // Closure wrapper for async/await
        return await withCheckedContinuation { continuation in
            
            // Establishing application bundle reference to the Developer-Token file
            guard let developerIdTokenFile = Bundle.main.path(forResource: "Developer-Token", ofType: nil) else {
                
                // Resuming the closure by returning a nil. This is a failed scenario.
                continuation.resume(returning: nil)
                return
            }

            do {
                // Loading the content of Developer-Token file as a String
                let developerIdToken = try String(contentsOfFile: developerIdTokenFile).replacingOccurrences(of: "\n", with: "")
                
                // Authorizing edgeEngine Runtime. Passing the content of Developer-Token file
                self.mimikClientLibrary.authorizeWithDeveloperIdToken(developerIdToken: developerIdToken) { result in
                    
                    // Retrieving the Access Token from the result of the authorization call
                    guard let edgeEngineAccessToken = result.tokens?.accessToken else {
                        
                        // Resuming the closure by returning a nil. This is a failed scenario.
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    // Resuming the closure by returning the Access Token
                    continuation.resume(returning: edgeEngineAccessToken)
                }
                                
            } catch {
                // Resuming the closure by returning a nil. This is a failed scenario.
                continuation.resume(returning: nil)
                return
            }
        }
    }

    // Asynchronous method deploying the edge microservice under the
    // edgeEngine Runtime and returning an object representing it
    // It requires Access Token as a parameter
    func deployRandomNumberMicroservice(edgeEngineAccessToken: String) async -> MIMIKMicroservice? {
        
        // Closure wrapper for async/await
        return await withCheckedContinuation { continuation in
            
            // Establishing application bundle reference to the randomnumber_v1.tar file
            guard let imageTarPath = Bundle.main.path(forResource: "randomnumber_v1", ofType: "tar") else {
                
                // Resuming the closure by returning a nil. This is a failed scenario.
                continuation.resume(returning: nil)
                return
            }

            // Setting up the deployment configuration object with hardcoded values for simplicity.
            let config = MIMIKMicroserviceDeploymentConfig.init(imageName: "randomnumber-v1", containerName: "randomnumber-v1", baseApiPath: "/randomnumber/v1", envVariables: [:])
            
             // Deploying the Random Number edge microservice. Passing the Access Token, deployment configuration object and a path to the randomnumber_v1.tar file
            self.mimikClientLibrary.deployMicroservice(edgeEngineAccessToken: edgeEngineAccessToken, config: config, imageTarPath: imageTarPath) { microservice in
            
                // Resuming the closure by returning reference to the deployed edge microservice
                continuation.resume(returning: microservice)
            }
        }
    }

    // A new asynchronous method returning a randomly generated number from the deployed edge microservice
    func generateRandomNumber() async -> Int {
        
        // Getting a reference to the deployed edge microservice's base API path
        guard let microserviceBaseApiPath = self.microservice?.baseApiPath() else {
            
            // Returning a zero. This is a failed scenario.
            return 0
        }
        
        // Getting a url to the edgeEngine Runtime instance. This includes a self-managed service port
        let edgeEngineServiceLink = self.mimikClientLibrary.edgeEngineServiceLink()
        
        // Defining the Random Number endpoint on the deployed edge microservice
        let microserviceEndpoint = "/randomNumber"
        
        // Combining the edgeEngine Runtime instance url with the deployed edge microservice's base API and the Random Number endpoint
        let microserviceFullUrlString = edgeEngineServiceLink + microserviceBaseApiPath + microserviceEndpoint
        
        // Creating a URL object from the combined url string
        guard let microserviceFullUrl = URL.init(string: microserviceFullUrlString) else {
            
            // Returning a zero. This is a failed scenario.
            return 0
        }
        
        // Closure wrapper for async/await
        return await withCheckedContinuation { continuation in
            
            // Creating a URLRequest object from the URL object
            let urlRequest = URLRequest.init(url: microserviceFullUrl)
            
            // using Alamofire networking library to make the HTTP call, parse the response and do basis error checking
            AF.request(urlRequest).responseJSON { response in
                
                // Determining the success or failure of the HTTP call
                switch response.result {
                case .success(let data):
                    
                    // Attempting the extract the random number value as an Int
                    guard let intValue = data as? Int else {
                        
                        // Resuming the closure by returning a 0. This is a failed scenario.
                        continuation.resume(returning: 0)
                        return
                    }
                    
                    // Resuming the closure by returning random number value
                    continuation.resume(returning: intValue)
                    
                case .failure(_):
                    
                    // Resuming the closure by returning a nil. This is a failed scenario.
                    continuation.resume(returning: 0)
                }
            }
        }
    }
}
