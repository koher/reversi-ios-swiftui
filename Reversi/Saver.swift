import SwiftUI
import Foundation
import ReversiLogics

final class Saver {
    private static let url: URL = .init(fileURLWithPath: (NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first! as NSString).appendingPathComponent("Game"))
    
    private var state: SavedState?
    
    func load() throws -> SavedState {
        if let state = self.state { return state }
        self.state = try SavedState(data: Data(contentsOf: Saver.url))
        return self.state!
    }
    
    func save(_ state: SavedState) throws {
        if state == self.state { return }
        self.state = state
        try state.data.write(to: Self.url, options: .atomic)
    }
}
