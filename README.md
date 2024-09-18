---
title: "Creating a Simple iOS Application that Uses an edge microservice"
metaTitle: "Creating a Simple iOS Application that Uses an edge microservice"
metaDescription: "Creating a Simple iOS Application that Uses an edge microservice"
seo: "mimik, edge, mimOE, tutorial, microservice, software development, deployment, iOS, iPadOS, iPhone, automation, cell phone"
---

# Objective

The objective of this tutorial is to demonstrate how to modify a small iOS application to use a microservice at the edge. The application code will use the mimik Client Library to access an edge microservice that generates a random number on demand.

# Intended Readers

The intended readers of this document are software developers who want to familiarize themselves with mimik application development on iOS using the mimik Client Library.


# What You'll Be Doing
In this tutorial, you are going to fix a bug in an existing iOS application. The application is a simple iOS application that is supposed to generate a random number when a button is tapped. However, there is a problem. The application does not generate a random number as expected, as shown in Figure 1, below.
Of course, you could fix the code by just using the Swift Standard Library `random(in:)` method to generate the random number directly in the code. However, we're going to take another approach. We're going to use the broken code as an opportunity to learn how to program iOS application code to bind to an edge microservice that provides a random number on demand.
In this tutorial, you'll be doing the following tasks to fix the iOS application. The tasks below describe using an edge microservice to generate the random number that the application will display when a button is tapped.

These tasks are:

* Clone the example application code from GitHub
* Configure the example application to include the mimik Client Library using [CocoaPods](https://guides.cocoapods.org). We have setup these references in the Podfile file at the project level for you.
* Configure the example application with the mimik Developer ID Token that will be used to generate the Access Token required to work with the edge microservice running under the mimOE Runtime.
* Modify the example application by adding code that will do the following:
  * Initialize the mimik Client Library.
  * Use the mimik Client Library to start the mimOE Runtime.
  * Use the mimik Client Library with an existing Developer ID Token to generate and retrieve the Access Token.
  * Deploy an edge microservice using the Access Token.
  * Request a random number from the deployed edge microservice.

In terms of doing the actual programming, after we've identified the problem area, we'll alter the files that store the configuration information about the Developer ID Token and mimOE License. You'll copy the values from the mimik Developer Console.

Then, after the configuration is complete, we'll execute three phases of coding to do the work of actually getting the edge microservice up and running. The coding will take place in `MainActivity.swift` and `ContentView.swift` files.

In the first phase, we stub out the methods that relate to each programming step. Then, in the second phase, we'll add code to the methods in an isolated manner within the tutorial so that you can learn the reasoning and details about each function. Finally, we'll display the completed `MainActivity.swift` and `ContentView.swift` files that have all the code for all the methods. At that point, you'll be able to run the fixed code on an iOS Device.

Also, be advised that the example application source that you'll clone from GitHub has a branch named `completed_code`. This branch contains a version of the iOS application that has all the code you will be adding throughout the tutorial. You can checkout this branch on your local machine and run that code, should you experience difficulties running the code you've developed.

# Technical Prerequisites

In order to get full benefit from this article, the reader should have a working knowledge of the following concepts and techniques:

- A device running the latest iOS version.
- A familiarity of working with mimik Client Library components as described in [this Key Concepts article](../../key-concepts/09-index).
- An understanding of the mimik Client Library components integration and initializiation process as layed out in [this article](11-index).
- An understanding of how to [start](../tutorials/12-index#startingedgeengine) the mimOE Runtime in an iOS application.
- An understanding of how to generate a mimOE [Access Token](../tutorials/12-index#creatinganaccesstoken).

|**NOTE:** <br/><br/>Working with the iOS Simulator and the mimik Client Libraries entails some special consideration. For more more information about iOS Simulator support see [this tutorial](../tutorials/12-index#workingwithaniossimulator).|
|----------|

# Working with the Example Application and the mimik Client Library

The sections below describe the details of the steps required to fix the broken application code using the mimik Client Library. The mimik Client Library simplifies usage and provides straightforward interfaces to streamline mimOE startup, authorization, and microservice deployment at the edge.

# Getting the Source Code

As mentioned above, you'll be modifying an existing iOS application to fix a bug in the code. The application you'll modify is an Xcode project. The application code already has all the UI elements and initialization behavior needed to get the code up and running. The code is operational, but as mentioned, it's buggy.

The place to start is cloning the code from GitHub and loading it into Xcode.

Execute the following command to clone the example code from GitHub:

```
git clone https://github.com/mimikgit/random-number-generator-iOS.git
```

# Adding the mimik Client Library components to the Application Source Code

As mentioned above, the mimik Client Library in a form of [EdgeCore](https://github.com/mimikgit/cocoapod-EdgeCore/releases) and [mimOE-SE-iOS-developer](https://github.com/mimikgit/cocoapod-mimOE-SE-iOS-developer/releases) (or [mimOE-SE-iOS](https://github.com/mimikgit/cocoapod-mimOE-SE-iOS/releases/)) cocoapods, needs to be made available to the application source code.

We have setup these references in the Podfile file at the project level for you.

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

Go to the mimik Developer Portal and generate the Developer ID Token from an edge project. 

Once generated, copy the Developer ID Token and then paste it into `Developer-ID-Token` file, replacing any existing content already there. Save and Close the file.


**Step 4:** Continue by editing the `Developer-mimOE-License` file with:

```
open Developer-mimOE-License
```

Go to the mimik Developer Portal and copy the Developer mimOE License from there. 

Learn more about the process by reading this the tutorial [Getting the edgeEngine license and Identity server values from mimik Developer Portal](./02-index)

Once copied, paste the mimOE License into the `Developer-mimOE-License` file, replacing any existing content already there. Save and Close the file.


**Step 5:** From the command line run the following command in your project directory.

```
open Random-Number-Generator-Example.xcworkspace
```

Figure 2 below shows the command line instructions described previously, from `Steps 1-5`.

| ![code in Xcode](../images/tutorials/iOS-01/iOS-command-line-output.png) |
|-----|
|**Figure 2:**  Command line output example for `Steps 1-5`|


Now that references and configurations have been set, it's time to get into the business of programming to the microservice at the edge.


# Identifying the Bug

As mentioned at the beginning of this tutorial, our objective is to fix a bug that is preventing the example application from displaying a random number when a button is tapped on the screen of the iOS device. The bad behavior we need to fix is in the `MainActivity.swift` file. The listing below shows the faulty code. The error is at `Line 11`.

```
import Foundation

final class MainActivity: NSObject {
    
    override init() {
        super.init()
    }

    // Buggy synchronous method that always returns the same number
    func generateRandomNumber() -> Int {
        return 60
    }
}
```
Figure 3 below displays a version of the faulty code within the XCode IDE.
Notice that the code returns a hard-coded value of 60 in the `generateRandomNumber()` method at `Line 11`. This is the root cause. The work we'll do moving forward will remedy this issue. We're going to make the fix by using a microservice at the edge as we discussed earlier.


# Implementing the Fix

In order to fix the application code we'll be doing the following in the `MainActivity.swift` and `ContentView.swift` files.

* Importing the mimik Client Library into the Project
* Creating an instance of the mimik Client Library
* Inserting the Method Placeholders
* Modifying the inserted Method Placeholders in MainActivity
* Modifying the ContentView code to call the fixed method

The mimik Client Library interface is represented in code as `EdgeClient` class, and we'll initialize its instance into a `let edgeClient` constant in one of the code examples below. 


# Importing the mimik Client Library components into the Project

In order to be able to start calling the mimik Client Library and `Alamofire` networking library interfaces, we need to import the following modules in our class. We do this by inserting the `import` statements in the `MainActivity.swift` file as shown below `Lines 2-4`:

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
}
```

# Creating an instance of the mimik Client Library components

In order to be able to start using the mimik Client Library interface we need to create its instance. We do this by establishing `let edgeClient` constant in the `MainActivity.swift` file as shown below in `Lines 17-20`. `edgeClient` will be providing our code with the mimik Client Library interface access.

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

We want to transform the application to start using the new edge microservice design paradigm. To beging the work we add a few placeholder methods in the `MainActivity.swift` file as shown below in `Lines 30-48`.

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
    
    // Asynchronous method returning the success or failure of mimOE Runtime startup
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

We want to make the deployed microservice at the edge available for the `ContentView.swift` code to call. We're doing this so that the rendering view can get the randomly generated number when the user taps on its button. In order to implement the microservice that generates a random number we need an ordered sequence of actions to execute successfully during the `MainActivity.swift` initialization in `init()`.
 
The four added methods are marked with `async` as asynchronous. We'll encapsulate asynchronous actions with a `Task{}` code wrapper as shown below in the code for the `init()`  method at `Lines 4-19`.
 
First, the mimOE Runtime needs to be started as shown below on `Line 6`. Second, we need to retrieve the Access Token as shown below on `Line 11`. Third, the edge microservice needs to be deployed which is done at `Line 16` below. 
 
The code below is commented on. Take a moment to review statements using the code comments as your guide. Then, if you're following along by doing live programming against the tutorial code you downloaded from GitHub, modify the `init()` method code in the `MainActivity.swift` file as shown below:
 
```
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
```

# Modifying `start()`

We need to get the mimOE Runtime running. Once the mimOE Runtime is up and running we'll be able to deploy the edge microservice to it. We'll get mimOE Runtime running by calling the relevant [method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeengineclient/startedgeengine(parameters:)) of the mimik Client Library.

In terms of the details of the `start()` function, first, we load the mimOE License from the `Developer-mimOE-License` file at `Lines 4-9`. Then we call the relevant [method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeengineclient/startedgeengine(parameters:)) of the mimik Client Library and return the result at `Lines 12-19`.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `start()` method code in the `MainActivity.swift` file as shown below.

```
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
```

# Modifying `accessToken()`

Once we have the mimOE Runtime running, we also need to have an Access Token for it generated. We do this so that we can deploy and call the edge microservice. In order to accomplish this task we need to call the relevant [method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)) of the mimik Client Library.
 
The [authorize method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)) of the mimik Client Library requires the Developer ID Token in order to work. We previously saved the Developer ID Token to the `Developer-ID-Token` file. 

In order to implement the authentication code, we need to find the application's bundle reference to the `Developer-ID-Token` file and load its contents into the `let developerIdToken` constant as shown in `Lines 4-9`.

At this point, we are ready to make a call to the mimik Client Library's [authorize method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/authorizedeveloper(developeridtoken:edgeengineidtoken:)). We send the `developerIdToken` as the function parameter, as shown below at line `Line 12`.

Next, we attempt to load the Access Token as `let accessToken` shown at `Lines 15-18` from the authorization result. If successful, we return a success with the Access Token at `Line 21`. If unsuccessful we return a failure as shown on `Line 25`.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `accessToken()` method code in the `MainActivity.swift` file as shown below.

```
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
```

# Modifying `deployMicroservice()`

At this point, we're going to deploy the edge microservice to the mimOE Runtime. For this, we need to call the relevant [method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) of the mimik Client Library, which requires the Access Token being passed through as the `edgeEngineAccessToken` parameter as shown in `Line 15` below.

The [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) method of the mimik Client Library also requires a file path to where the edge microservice is bundled. In our case, the microservice is represented by the `randomnumber_v1.tar` file. This file resides in the application's bundle. We get a reference to the file at `Line 5`.

Additionally, the [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) of the mimik Client Library requires a [configuration](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/microservice/config) object. We've taken the liberty of configuring it using hardcoded values as shown in `Line 11`. This is done to make the code easier to understand. In a production setting, you'd want to put all the hard-coded values in a configuration file and name the values accordingly.

Now we have the deployment configuration setup and the path to the edge microservice file established. We also have the Access Token. Next, we call the [deploy method](https://mimikgit.github.io/cocoapod-EdgeCore/documentation/edgecore/edgeclient/deploymicroservice(edgeengineaccesstoken:config:imagetarpath:)) of the mimik Client Library, passing the `edgeEngineAccessToken`, `config` and `imageTarPath` objects as the parameters as shown below in `Line 15`.

If successful, we return a success with the deployed edge microservice at `Line 18`. If unsuccessful we return a failure as shown on `Line 21`.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `deployMicroservice()` method code in the `MainActivity.swift` file as shown below.

```
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
```

# Modifying `generateRandomNumberNew()`

Previously the buggy function, `generateRandomNumber()` just returned a hard-coded value of 60. In order to implement a fix, we want the new `generateRandomNumberNew()` method to return a truly random number. For this, we will make an HTTP call to the `randomNumber` endpoint on the deployed microservice at the edge and return the random value from the HTTP response. We'll use the `Alamofire` networking library's `request()` method to make this call.

Before we call the microservice at the edge, we need to get the Access Token ready. We will accomplish this by calling the `accessToken()` method at `Lines 4-9`.

In order to establish the full URL of the `randomNumber` endpoint on the deployed edge microservice, we first get an object reference to the already deployed edge microservice on `Lines 11-15`.

Next, we establish the full path URL to the edge microservice endpoint at `Lines 17-23`.

With all the prerequisites now established, we can use the `request()` method of the `Alamofire`library to call the endpoint on the deployed edge microservice `Line 26`.

Next, we look at the response result and if successful, return a success with the random number value as shown in `Line 33`. If there was an issue we return a failure at `Line 29`.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the `generateRandomNumber()` method code in the `MainActivity.swift` file as shown below.

```
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
```

We now have fully operational code in the `MainActivity.swift` file. Next, we'll change the code specific to this application's view in the `ContentView.swift` file so that we can see it in action on screen.

# Refactoring `ContentView.swift`

What we need to do now is to make a change where the view rendering code calls the deployed microservice at the edge; more specifically where the user taps on the button to get the randomly generated number.

The code `ContentView.swift` runs synchronously. The new and improved `generateRandomNumberNew()` instance method of `MainActivity` runs asynchronously. This means a `Task{}` code wrapper needs to be used to encapsulate the call in `Line 21`. 

Then we switch to the new asynchronous `generateRandomNumberNew()` method at `Line 23`. Now, when a user taps the button on the screen of an iOS device, a random number will appear.

Take a moment to review the statements in the code below using the comments as your guide. If you're following along using the code downloaded from GitHub, modify the code in the `ContentView.swift` file as shown below.

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
                
                Task {
                    // Calling the repaired asynchronous method
                    guard case let .success(generatedNumber) = await mainActivity.generateRandomNumberNew() else {
                        return
                    }
                    
                    // Setting the view's new random number
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

We now have fully operational code in the `ContentView.swift` file as well. Your application is working correctly once again. And now it's [edgified] (https://devdocs.mimik.com/introduction/01-index)!

# Viewing the Completed Code

The sections above showed you the details that go with getting the configuration settings, import statements, class variables and methods in place in order to implement an edge microservice. The microservice we added fixes the bug that was in the example application. 

If you've followed along by inserting and adding code as instructed throughout this tutorial, running the code is a matter of using the capabilities provided by Xcode to run the code on the attached iOS device.

If for some reason you can't get your code up and running, you can use the working version of this code that ships in the cloned repository. It is in a branch named `completed_code`. You can run that code by using the following steps:

* `git checkout completed_code`

* cd to the project directory where the `Podfile` file is.

* `pod install --repo-update`

Additionally don't forget to save your Developer ID Token to the `Developer-ID-Token` and edge developer License to `Developer-mimOE-License` there as well. Then open the project in Xcode. Then, build and run the code on the attached iOS device.

| ![after-deployment](../images/tutorials/iOS-01/iOS-random-number-working.png)|
|----|
|**Figure 4:** The example application with the working randomization code from the  microservice at the edge |

**Congratulations!** You have completed the example application that uses a microservice at the edge to provide behavior to fix the operational bug in an application. Remember, the application was unable to display a random number each time the **Get Random Number** button was tapped. Now by binding the button tap handler to make a call to the edge microservice, it does.

# Review
In this document, you learned the following:

- How to configure the example application to get the mimik Client Library cocoapods
- How to configure the example application with Developer ID Token credentials
- How to instantiate and start the mimOE Runtime using the mimik Client Library
- How to use a Developer ID Token to authorize an mimOE Runtime and generate an Access Token
- How to use a generated Access Token to deploy a microservice at the edge
- How to make a request to a microservice at the edge to retrieve a random value
