import SwiftUI
import UIKit
import SwiftyReversi
import ReversiLogics

struct BoardView: UIViewRepresentable {
    let board: Board
    let action: (Int, Int) -> Void
    let animationCompletion: (() -> Void)?
    
    init(_ board: Board, action: @escaping (Int, Int) -> Void, animationCompletion: (() -> Void)?) {
        self.board = board
        self.action = action
        self.animationCompletion = animationCompletion
    }
    
    func makeUIView(context: Context) -> __BoardView {
        let view: __BoardView = .init()
        view.delegate = context.coordinator
        view.setBoard(board, animated: false, completion: nil)
        return view
    }
    
    func updateUIView(_ uiView: __BoardView, context: Context) {
        context.coordinator.action = action
        uiView.setBoard(board, animated: animationCompletion != nil) { _ in
            animationCompletion?()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    final class Coordinator: _BoardViewDelegate {
        var action: (Int, Int) -> Void
        init(action: @escaping (Int, Int) -> Void) {
            self.action = action
        }
        func boardView(_ boardView: __BoardView, didSelectCellAtX x: Int, y: Int) {
            action(x, y)
        }
    }
}
