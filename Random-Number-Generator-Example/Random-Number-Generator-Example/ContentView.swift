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
