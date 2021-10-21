import Foundation

final class MainActivity: NSObject {
    
    override init() {
        super.init()
    }

    // Synchronous method that was supposed to return a randomly generated number
    func generateRandomNumber() -> Int {
        return 60
    }
}
