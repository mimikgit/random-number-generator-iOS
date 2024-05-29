import SwiftUI

struct ContentView: View {
    
    @State private var randomNumber: Int = 0
    @State private var mainActivity = MainActivity()

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            
            Text("mimik Random Number Generator")
                .font(.title2)

            Button.init("GET RANDOM NUMBER") {
                
                // Currently calling the buggy synchronous method that always returns the same number
                randomNumber = mainActivity.generateRandomNumber()
                
            }.tint(Color.blue)
            
            Text("Got \(randomNumber)")
                .font(.body)
        }
    }
}
