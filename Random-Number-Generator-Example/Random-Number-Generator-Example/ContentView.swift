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
