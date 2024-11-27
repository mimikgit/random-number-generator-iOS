# Objective

The objective of this tutorial is to demonstrate how to modify a small iOS application to use a microservice at the edge. The application code will use the mimik Client Library to access an edge microservice that generates a random number on demand.

# Intended Readers

The intended readers of this document are software developers who want to learn about the process of using edge microservices and the mimik Client Library in the iOS application environment.


# What You'll Be Doing
In this tutorial, you are going to fix a bug in an existing iOS application. The application is a simple example that is supposed to generate a random number when a button is tapped. But, there is a problem. The application does not generate a random number as expected, as shown in Figure 1, below.
Of course, you could fix the code by just using the Swift Standard Library `random(in:)` method to generate the random number directly in the code. However, we're going to take another approach. We're going to use the broken code as an opportunity to learn how to program iOS application code to bind to an edge microservice that provides a random number on demand.

In this tutorial, you'll be doing the following tasks to fix the iOS application:

* Clone the example application code from GitHub.
* Configure the example application to include the mimik Client Library using [CocoaPods](https://guides.cocoapods.org). We have setup the mimik cocoapod references in the `Podfile` file at the project level for you.
* Configure the example application with the mimik Developer ID Token and mim OE license that will be used to generate the Access Token required to work with the edge microservice.
* Modify the example application by adding code that will do the following:
  * Initialize the mimik Client Library.
  * Use mimik Client Library to start the mim OE Runtime.
  * Use mimik Client Library with an existing Developer ID Token to generate the Access Token.
  * Deploy an edge microservice using the Access Token.
  * Request a random number from the deployed edge microservice using the Access Token.

In terms of doing the actual programming, after we've identified the problem area, we'll alter the files storing the configuration information about the Developer ID Token and mim OE License. You'll copy the values from the [mimik Developer Console](https://console.mimik.com).

Then, after the configuration is complete, we'll execute three phases of coding to do the work of actually getting the edge microservice up and running. The coding will take place in `MainActivity.swift` and `ContentView.swift` files.

In the first phase, we stub out the methods that relate to each programming step. Then, in the second phase, we'll add code to the methods in an isolated manner within the tutorial so that you can learn the reasoning and details about each function. Finally, we'll display the completed `MainActivity.swift` and `ContentView.swift` files that have all the code for all the methods. At that point, you'll be able to run the fixed code on an iOS Device.

Also, be advised that the example application source that you'll clone from GitHub has a branch named `completed_code`. This branch contains a version of the iOS application that has all the code you will be adding throughout the tutorial. You can checkout this branch on your local machine and run that code, should you experience difficulties running the code you've developed.

# Prerequisites

Connecting a **real iOS device** to the Mac computer and selecting it as the target in Xcode later on, when the project opens. This example application will not work with an iOS Simulator.

|**NOTE:** <br/><br/>Working with the iOS Simulator and the mimik Client Libraries entails some special consideration. For more more information about iOS Simulator support see [this tutorial](https://devdocs.mimik.com/tutorials/01-submenu/02-submenu/03-index).|
|----------|

# Working with the Example Application and the mimik Client Library

The sections below describe the details of the steps required to fix the broken application code using the mimik Client Library. The mimik Client Library simplifies usage and provides straightforward interfaces to streamline mim OE startup, authorization, and microservice deployment at the edge.

# Getting the Source Code

As mentioned above, you'll be modifying an existing iOS application to fix a bug in the code. The application you'll modify is an Xcode project. The application code already has all the UI elements and initialization behaviour needed to get the code up and running. The code is operational, but as mentioned, it's buggy.

The place to start is cloning the code from GitHub and loading it into Xcode.

Execute the following command to clone the example code from GitHub:

```
git clone https://github.com/mimikgit/random-number-generator-iOS.git
```

# Adding the mimik Client Library cocoapods

As mentioned above, the mimik Client Library comes in a form of [EdgeCore](https://github.com/mimikgit/cocoapod-EdgeCore) and [mim-OE-ai-SE-iOS-developer](https://github.com/mimikgit/cocoapod-mim-OE-ai-SE-iOS-developer) cocoapods, which need to be made available to the application source code.

We have setup these references in the `Podfile` file at the project level for you.

**Step 1**:** From the command line run the following command to get to the Xcode project directory.

```
cd random-number-generator-iOS/Random-Number-Generator-Example/
```

**Step 2**:** From the command line run the following command (from inside the Xcode project directory).

```
pod install --repo-update
```

**Step 3:** Start editing the `Developer-ID-Token` file with:

```
open Developer-ID-Token
```

Go to the [mimik Developer Console](https://console.mimik.com) and generate the Developer ID Token from an edge project that you create.

Once generated, copy the Developer ID Token and then paste it into `Developer-ID-Token` file, replacing any existing content already there. Save and Close the file.


**Step 4:** Continue by editing the `Developer-mim-OE-License` file with:

```
open Developer-mim-OE-License
```

Go to the [mimik Developer Console](https://console.mimik.com) and copy the Developer mim OE (edge) License from there. 

Learn more about the process by reading [this](https://devdocs.mimik.com/tutorials/01-submenu/01-submenu/02-index) tutorial.

Once copied, paste the mim OE License into the `Developer-mim-OE-License` file, replacing any existing content already there. Save and Close the file.


**Step 5:** From the command line run the following command in your project directory.

```
open Random-Number-Generator-Example.xcworkspace
```

Figure 1 below shows the command line instructions described previously, from `Steps 1-5`.

| ![code in Xcode](../../../images/tutorials/iOS-01/iOS-command-line-output.png) |
|-----|
|**Figure 1:**  Command line output example for `Steps 1-5`|


Now that references and configurations have been set, it's time to get into the business of programming to the microservice at the edge.


# Identifying the Bug

As mentioned at the beginning of this tutorial, our objective is to fix a bug that is preventing the example application from displaying a random number when a button is tapped on the screen of the iOS device as seen in Figure 2 below.

| ![iOS-buggy-behaviour](../../../images/tutorials/iOS-01/iOS-buggy-behaviour.png)|
|----|
|**Figure 2:** Buggy behaviour! A static value of 60 is being returned instead of a random number|


The bad behaviour we need to fix is in the `MainActivity.swift` file as seen in the XCode IDE in Figure 3 below.

| ![iOS-Xcode-project](../../../images/tutorials/iOS-01/iOS-Xcode-project.png)|
|----|
|**Figure 3:** Shows a version of the faulty code within the XCode IDE.|
Notice that the code returns a hard-coded value of 60 in the `generateRandomNumber()` method at `Line 16`. This is the root cause. We're going to make the fix by using a microservice at the edge instead, as we discussed earlier.


# Implementing the Fix

In order to fix the application code we'll be doing the following in the `MainActivity.swift` and `ContentView.swift` files.

* Importing the mimik Client Library into the Project
* Creating an instance of the mimik Client Library
* Inserting the Method Placeholders
* Modifying the inserted Method Placeholders in MainActivity
* Modifying the ContentView code to call the fixed method

The mimik Client Library interface is represented in code as [EdgeClient](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient) class, and we'll initialize its instance into a `let edgeClient` constant in one of the code examples below. 


# Creating an instance of the mimik Client Library components

First, we need to import the relevant mimik Client Library modules in our MainActivity class by inserting the `import` statements as shown below.

Then, in order to be able to start using the mimik Client Library interface we need to create its instance. We do this by establishing the `let edgeClient` constant in the `MainActivity.swift` file as shown below. `edgeClient` constant will be providing our code with the mimik Client Library interface access.

```
import Foundation
import EdgeCore
import EdgeEngine
import Alamofire

final class MainActivity: NSObject {
    
    override init() {
        super.init()
    }

    // Buggy synchronous method that always returns the same number
    func generateRandomNumber() -> Int {
        return 60
    }
    
    // mimik Client Library instance
    let edgeClient: EdgeClient = {
        return EdgeClient()
    }()
}
```

# Inserting the Method Placeholders

We want to transform the application to start using the new edge microservice design paradigm. To begin the work we add a few placeholder methods in the `MainActivity.swift` file as shown below.

The code is commented on to describe the intention of the particular placeholder methods.

```
import Foundation
import EdgeCore
import EdgeEngine
import Alamofire

final class MainActivity: NSObject {
    
    override init() {
        super.init()
    }

    // Buggy synchronous method that always returns the same number
    func generateRandomNumber() -> Int {
        return 60
    }
    
    // mimik Client Library instance
    let edgeClient: EdgeClient = {
        return EdgeClient()
    }()
    
    // Asynchronous method returning the success or failure of mim OE Runtime startup
    func start() async -> Result<Void, NSError> {
        return .failure(NSError(domain: "", code: 500))
    }

    // Asynchronous method returning the success or failure of generating an Access Token
    func accessToken() async -> Result<String, NSError> {
        return .failure(NSError(domain: "", code: 500))
    }

    // Asynchronous method returning the success or failure of deploying an edge microservice
    func deployMicroservice(accessToken: String) async -> Result<EdgeClient.Microservice, NSError> {
        return .failure(NSError(domain: "", code: 500))
    }

    // New asynchronous method returning a randomly generated number
    func generateRandomNumberNew() async -> Result<Int, NSError> {
        return .failure(NSError(domain: "", code: 500))
    }
}
```

The sections that follow will show the code for each method we're programming. Also, we'll describe the reasoning behind each of the additions we're making to the code in the `MainActivity.swift` and `ContentView.swift` files.


# Modifying the inserted Method Placeholders

In order to get the edge microservice installed and accessible we'll need to make the following changes in the `MainActivity.swift` and `ContentView.swift` files.

* refactor the `MainActivity.swift` initialization method `init()`
* modify the `MainActivity.swift` method `start()`
* modify the `MainActivity.swift` method `accessToken()`
* modify the `MainActivity.swift` method `deployMicroservice()`
* modify the `MainActivity.swift` method `generateRandomNumberNew()`
* modify the `ContentView.swift` body


# Refactoring `init()`

We want to make the deployed microservice at the edge available for the `ContentView.swift` code to call. We're doing this so that the rendering view can get the randomly generated number whenever the user taps on its button. In order to implement the edge microservice that generates a random number we need an ordered sequence of actions to execute successfully during the `MainActivity.swift` initialization in `init()`.
 
The four added methods are marked with `async` as asynchronous. We'll encapsulate asynchronous actions with a `Task{}` code wrapper as shown below in the code for the `init()` method.
 
First, the mim OE Runtime needs to be started as shown below on `Line 6`. Second, we need to generate the Access Token as shown below on `Line 11`. Third, the edge microservice needs to be deployed which is done at `Line 16`. 
 
The code below is commented on. Take a moment to review statements using the code comments as your guide. Then, if you're following along by doing live programming against the tutorial code you downloaded from GitHub, modify the `init()` method code in the `MainActivity.swift` file as shown below:
 
```
override init() {
    super.init()
    
    Task {
        // Starting mim OE Runtime.
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
```

# Modifying `start()`

We need to get the mim OE Runtime running, so that we'll be able to deploy the edge microservice to it. We'll get mim OE Runtime running by calling the [start method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeengineclient/startedgeengine(parameters:)) on the mimik Client Library.

In terms of the details of the `start()` function, first, we load the mim OE License from the `Developer-mim-OE-License` file. Then we call the [start method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeengineclient/startedgeengine(parameters:)) on the mimik Client Library and return the result. Either a success or a failure.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `start()` method code in the `MainActivity.swift` file as shown below.

```
// Asynchronous method returning the success or failure of edgeEngine Runtime startup
func start() async -> Result<Void, NSError> {
    
    // Loading the content of the Developer-mimOE-License file as a String
    guard let file = Bundle.main.path(forResource: "Developer-mim-OE-License", ofType: nil), let license = try? String(contentsOfFile: file).replacingOccurrences(of: "\n", with: "") else {
        print(#function, #line, "Error")
        return .failure(NSError(domain: "Developer-mim-OE-License Error", code: 500))
    }
    
    // License parameter is the only parameter required for mim OE Runtime startup. There are other optional parameters also available.
    let params = EdgeClient.StartupParameters(license: license)
    
    // Using the mimik Client Library to start the mim OE Runtime
    switch await self.edgeClient.startEdgeEngine(parameters: params) {
    case .success:
        print(#function, #line, "Success")
        // Returning a success for mim OE startup
        return .success(())
    case .failure(let error):
        print(#function, #line, "Error", error.localizedDescription)
        // Returning a failure for mim OE startup
        return .failure(error)
    }
}
```

# Modifying `accessToken()`

Once we have the mim OE Runtime running, we also need to have an Access Token for it generated. We do this so that we can deploy and call the edge microservice. In order to accomplish this task we need to call the [authorization method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)) on the mimik Client Library.
 
The mimik Client Library [authorization method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)) requires a Developer ID Token in order to work. We previously saved the Developer ID Token to the `Developer-ID-Token` file. 

In order to implement the authentication code, first, we need to find the application's bundle reference to the `Developer-ID-Token` file and load its contents into the `let developerIdToken` constant as shown below.

At this point, we are ready to make a call to the mimik Client Library's [authorization method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)). We send the `developerIdToken` as the method's only parameter.

Next, we attempt to load the Access Token as `let accessToken` from the authorization result. If successful, we return a success with the Access Token. If unsuccessful, we return a failure.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `accessToken()` method code in the `MainActivity.swift` file as shown below.

```
// Asynchronous method returning the success or failure of generating an Access Token
func accessToken() async -> Result<String, NSError> {
    
    // Finding the application's bundle reference to the Developer-ID-Token file and loading its content
    guard let developerIdTokenFile = Bundle.main.path(forResource: "Developer-ID-Token", ofType: nil), let developerIdToken = try? String(contentsOfFile: developerIdTokenFile).replacingOccurrences(of: "\n", with: "") else {
        print(#function, #line, "Error")
        return .failure(NSError(domain: "Developer-ID-Token Error", code: 500))
    }
    
    // Calling mimik Client Library to generate the Access Token. Passing-in the Developer ID Token as the only parameter.
    switch await self.edgeClient.authorizeDeveloper(developerIdToken: developerIdToken) {
    case .success(let authorization):
        
        // Attempting to getting the access token from the authorization call response
        guard let accessToken = authorization.token?.accessToken else {
            print(#function, #line, "Error")
            return .failure(NSError(domain: "Access Token Error", code: 500))
        }
                    
        print(#function, #line, "Success", accessToken)
        // We have the Access Token, return a success
        return .success(accessToken)
        
    case .failure(let error):
        print(#function, #line, "Error", error.localizedDescription)
        // We don't have the Access Token, returning a failure.
        return .failure(error)
    }
}
```

# Modifying `deployMicroservice()`

At this point, we're going to deploy the edge microservice to the mim OE Runtime. For this, we need to call the [deployment method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) on the mimik Client Library, which requires the Access Token being passed through as its parameter.

The mimik Client Library [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) also requires a [configuration](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/microservice/config) object. We've taken the liberty of configuring it using hardcoded values as shown below. This is done to make the code easier to understand. In a production setting, you'd want to put all the hard-coded values in a configuration file and name the values accordingly.

Additionally, the mimik Client Library [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) also requires a file path to where the edge microservice is bundled. In our case, the microservice is represented by the `randomnumber_v1.tar` file. This file resides in the application's bundle.

Now we have the deployment configuration setup and the path to the edge microservice file established. We also have the Access Token. Next, we call the mimik Client Library [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)), passing the `accessToken`, `config` and `imageTarPath` values as parameters.

If all goes well, we return a success with the deployed edge microservice. If there is an issue we return a failure.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `deployMicroservice()` method code in the `MainActivity.swift` file as shown below.

```
// Asynchronous method returning the success or failure of deploying an edge microservice
func deployMicroservice(accessToken: String) async -> Result<EdgeClient.Microservice, NSError> {

    // Finding the application's bundle reference to the randomnumber_v1.tar file
    guard let imageTarPath = Bundle.main.path(forResource: "randomnumber_v1", ofType: "tar") else {
        print(#function, #line, "Error")
        return .failure(NSError(domain: "Tar file Error", code: 500))
    }
    
    // Setting up the edge microservice deployment configuration
    let config = EdgeClient.Microservice.Config(imageName: "randomnumber-v1", containerName: "randomnumber-v1", basePath: "/randomnumber/v1", envVariables: [:])
    
    // Using the mimik Client Library method to deploy the edge microservice, passing in the Access Token, deployment configuration and the reference to the randomnumber_v1.tar file
    switch await self.edgeClient.deployMicroservice(edgeEngineAccessToken: accessToken, config: config, imageTarPath: imageTarPath) {
    case .success(let microservice):
        print(#function, #line, "Success", microservice)
        // We have the deployed edge microservice reference, returning success.
        return .success(microservice)
    case .failure(let error):
        print(#function, #line, "Error", error.localizedDescription)
        // We failed to deploy the edge microservice, return a failure.
        return .failure(error)
    }
}
```

# Modifying `generateRandomNumberNew()`


Previously, the `generateRandomNumber()` function simply returned a hard-coded value of 60, which was clearly a bug. To resolve this, we'll implement a new method, `generateRandomNumberNew()`, that will fetch a truly random number. This will involve making an HTTP request to the `randomNumber` endpoint on the deployed edge microservice and returning the value from the response. We'll use Alamofire’s request() method to handle the HTTP call and retrieve the data.

Before we call the microservice at the edge, we need to get the Access Token ready. We will accomplish this by calling the `accessToken()` method.

In order to establish the full path URL to the `randomNumber` endpoint on the deployed edge microservice, we first get a reference to the deployed edge microservice.

Next, we establish the full path URL to the edge microservice endpoint.

With all the prerequisites established, we can use the `request()` method of the `Alamofire` library to call the endpoint on the deployed edge microservice.

Next, we look at the response result and if all goes well, return a success with the random number value. If there is an issue we return a failure.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `generateRandomNumberNew()` method code in the `MainActivity.swift` file as shown below.

```
// New asynchronous method returning a randomly generated number
func generateRandomNumberNew() async -> Result<Int, NSError> {
    
    // Getting the Access Token ready
    guard case let .success(accessToken) = await self.accessToken() else {
        print(#function, #line, "Error")
        // We don't have the Access Token, returning a failure.
        return .failure(NSError(domain: "Access Token Error", code: 500))
    }
    
    // Getting a reference to the deployed edge microservice
    guard case let .success(microservice) = await
            self.edgeClient.microservice(containerName: "randomnumber-v1", edgeEngineAccessToken: accessToken) else {
        print(#function, #line, "Error")
        // We don't have the reference, returning a failure.
        return .failure(NSError(domain: "Deployment Error", code: 500))
    }
    
    // Establishing the full path url to edge microservice's /randomNumber endpoint
    guard let endpointUrlComponents = microservice.urlComponents(withEndpoint: "/randomNumber"), let endpointUrl = endpointUrlComponents.url else {
        print(#function, #line, "Error")
        // We don't have the url, returning a failure.
        return .failure(NSError(domain: "Microservice Error", code: 500))
    }
    
    // Calling the edge microservice endpoint using the Alamofire networking library.
    let dataTask = AF.request(endpointUrl).serializingDecodable(Int.self)
    guard let value = try? await dataTask.value else {
        print(#function, #line, "Error")
        // We don't have the random number, returning a failure.
        return .failure(NSError(domain: "Decoding Error", code: 500))
    }
    
    print(#function, #line, "Success", value)
    // We have the random number from the edge microservice, returning a success with the value
    return .success(value)
}
```

We now have fully operational code in the `MainActivity.swift` file. Next, we'll change the code specific to this application's view in the `ContentView.swift` file so that we can see it in action on screen.

# Refactoring `ContentView.swift`


To implement the new functionality, we need to modify the view rendering code so that it calls the deployed microservice at the edge—specifically, when the user taps the button to generate a random number.

Currently, the code in ContentView.swift runs synchronously, while the new `generateRandomNumberNew()` method in `MainActivity` runs asynchronously. This means we need to wrap the asynchronous call inside a Task {} block to properly handle the asynchronous execution.

Once we switch to using the asynchronous `generateRandomNumberNew()` method, the app will be able to fetch a random number when the user taps the button on the iOS device screen.

Please take a moment to review the code below, paying close attention to the comments for guidance. If you’re following along with the GitHub code, make sure to update the `ContentView.swift` file as shown below.

```
import SwiftUI

struct ContentView: View {
    
    @State private var randomNumber: Int = 0
    @State private var mainActivity = MainActivity()
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            
            Text("mimik Random Number Generator")
                .font(.title2)
            
            Button.init("GET RANDOM NUMBER") {
                
                // Wrapping around the asynchronous call with Task
                Task {
                    // Calling the new asynchronous generateRandomNumberNew method
                    guard case let .success(generatedNumber) = await mainActivity.generateRandomNumberNew() else {
                        // We don't have the random number, just returning then
                        return
                    }
                    
                    // We have a new random number, so we'll set the view's UI with the new value
                    randomNumber = generatedNumber
                }
                
            }.tint(Color.blue)
            
            // Showing the current random number value on the screen
            Text("Got \(randomNumber)")
                .font(.body)
        }
    }
}
```

We now have fully operational code in the `ContentView.swift` file as well. Your application is working correctly once again. And now it's [edgified](https://devdocs.mimik.com/introduction/01-index)!

# Viewing the Completed Code

The previous sections covered the steps required to configure the settings, import necessary libraries, and define class variables and methods to implement the edge microservice. The microservice we added resolved the bug in the example application.

If you've followed the tutorial and implemented the code as instructed, running the application is straightforward. Simply use Xcode to deploy the app to your attached iOS device.

If you encounter any issues getting your code to run, don't worry—you can always refer to the working version of the code available in the cloned repository. This version is located in the `completed_code` branch. To run the completed code, follow the steps below:

* `git checkout completed_code`
* cd to the project directory where the `Podfile` file is.
* `pod install --repo-update`
* Saving your Developer ID Token to the `Developer-ID-Token` file.
* Saving your mim OE (Edge) developer License to the `Developer-mim-OE-License` file. 
* Opening the project **workspace** in Xcode.
* Attaching and selecting a **real iOS device** as the target. This won't work with the iOS simulator.
* Runing the code on the attached iOS device.

| ![after-deployment](../../../images/tutorials/iOS-01/iOS-random-number-working.png)|
|----|
|**Figure 4:** The example application with the working randomization code from the  microservice at the edge |

**Congratulations!** You have completed the example application tutorial that uses a microservice at the edge to provide behaviour to fix the operational bug in an application. Remember, the application was unable to display a random number each time the **Get Random Number** button was tapped. Now by binding the button tap handler to make a call to the edge microservice, it does.

# Additional reading

In order to get more out of this article, the reader could further familiarize themselves with the following concepts and techniques:

- [Understanding the mimik Client Library for iOS](https://devdocs.mimik.com/key-concepts/10-index).
- [Creating a Simple iOS Application that Uses an edge microservice](https://devdocs.mimik.com/tutorials/01-submenu/02-submenu/01-index).
- [Integrating the mimik Client Library into an iOS project](https://devdocs.mimik.com/tutorials/01-submenu/02-submenu/02-index).
- [Working with mim OE in an iOS project](https://devdocs.mimik.com/tutorials/01-submenu/02-submenu/03-index).
- [Working with edge microservices in an iOS project](https://devdocs.mimik.com/tutorials/01-submenu/02-submenu/04-index).


# Review
In this document, you learned the following:

- How to configure the example application to integrate the mimik Client Library cocoapods
- How to configure the example application with Developer ID Token credentials
- How to get a mim OE License and start the mim OE Runtime using the mimik Client Library
- How to use a Developer ID Token to authorize a mim OE Runtime and generate an Access Token for it
- How to use a generated Access Token to deploy a microservice at the edge
- How to make a request to a microservice at the edge to retrieve a random value
