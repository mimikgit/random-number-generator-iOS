import SwiftUI

struct ContentView: View {
    
    // View's random number value instance variable
    @State private var randomNumber: Int = 0
    // View's MainActivity class instance variable
    @State private var mainActivity = MainActivity()

    // View's body
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            
            // View's title text
            Text("mimik Random Number Generator")
                .font(.title2)

            // View's button with an action closure
            Button.init("GET RANDOM NUMBER") {
                
                // Calling the fixed, new asynchronous method in a await/async wrapper
                Task {
                    randomNumber = await mainActivity.generateRandomNumber()
                }

            }.tint(Color.blue)
            
            // Showing the current random number value on the screen
            Text("Got \(randomNumber)")
                .font(.body)
        }
    }
}
