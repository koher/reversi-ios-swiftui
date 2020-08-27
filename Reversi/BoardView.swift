import SwiftUI
import UIKit
import SwiftyReversi
import ReversiLogics

struct BoardView: UIViewControllerRepresentable {
    let board: Board
    let action: (Int, Int) -> Void
    let animationCompletion: (() -> Void)?
    
    init(_ board: Board, action: @escaping (Int, Int) -> Void, animationCompletion: (() -> Void)?) {
        self.board = board
        self.action = action
        self.animationCompletion = animationCompletion
    }
    
    func makeUIViewController(context: Context) -> _BoardViewController {
        _BoardViewController(board, action: action)
    }
    
    func updateUIViewController(_ uiViewController: _BoardViewController, context: Context) {
        uiViewController.setBoard(board, animated: animationCompletion != nil, completion: animationCompletion)
    }
}

final class _BoardViewController: UIHostingController<_BoardView> {
    private var board: Board
    private var animatedBoard: Board
    var action: (Int, Int) -> Void
    
    private var animationWorkItem: DispatchWorkItem?

    init(_ board: Board, action: @escaping (Int, Int) -> Void) {
        self.board = board
        self.animatedBoard = board
        self.action = action
        super.init(rootView: _BoardView(board, action: action))
    }
    
    func setBoard(_ board: Board, animated isAnimated: Bool, completion: (() -> Void)?) {
        if board == self.board { return }

        animationWorkItem?.cancel()
        animationWorkItem = nil
        
        self.animatedBoard = self.board
        self.board = board

        if isAnimated {
            animateDiff(BoardDiff(from: animatedBoard, to: board).result[...], completion: completion)
        } else {
            rootView = _BoardView(board, action: action)
            completion?()
        }
    }
    
    private func animateDiff(_ diff: ArraySlice<(disk: Disk?, x: Int, y: Int)>, completion: (() -> Void)?) {
        guard let (disk, x, y) = diff.first else {
            completion?()
            return
        }
        animatedBoard[x, y] = disk
        rootView = _BoardView(animatedBoard, action: action)
        let workItem: DispatchWorkItem = .init { [weak self] in
            self?.animateDiff(diff[(diff.startIndex + 1)...], completion: completion)
        }
        self.animationWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct _BoardView: View {
    let board: Board
    let action: (Int, Int) -> Void
    
    init(_ board: Board, action: @escaping (Int, Int) -> Void) {
        self.board = board
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(board.yRange) { y in
                HStack(spacing: 2) {
                    ForEach(board.xRange) { x in
                        CellView(disk: board[x, y]) {
                            action(x, y)
                        }
                    }
                }
            }
        }
        .background(Color.dark)
        .border(Color.dark, width: 2)
        .aspectRatio(1, contentMode: .fit)
    }
}

struct _BoardView_Previews: PreviewProvider {
    static var previews: some View {
        _BoardView(Board(width: 8, height: 8)) { _, _ in }
    }
}
