import SwiftyReversi
import Dispatch

final class Computer {
    static let shared: Computer = .init()
    
    private var board: Board?
    private var workItem: DispatchWorkItem?
    
    func move(for board: Board, completion: @escaping (Int, Int) -> Void) {
        if board == self.board { return }
        self.board = board
        let workItem = DispatchWorkItem {
            guard let (x, y) = board.validMoves(for: .dark).randomElement() else { return }
            completion(x, y)
        }
        self.workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: workItem)
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
        board = nil
    }
}
