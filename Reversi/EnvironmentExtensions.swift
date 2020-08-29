import SwiftUI

struct ComputerKey: EnvironmentKey {
    static let defaultValue: Computer = .init()
}

struct SaverKey: EnvironmentKey {
    static let defaultValue: Saver = . init()
}

extension EnvironmentValues {
    var computer: Computer {
        get { self[ComputerKey.self] }
        set { self[ComputerKey.self] = newValue }
    }
    
    var saver: Saver {
        get { self[SaverKey.self] }
        set { self[SaverKey.self] = newValue }
    }
}
