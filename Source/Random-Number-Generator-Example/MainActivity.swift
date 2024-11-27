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
