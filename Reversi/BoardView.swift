import SwiftUI
import SwiftyReversi

// TODO: Implement appropriate animations.
struct BoardView: View {
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

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(Board(width: 8, height: 8)) { _, _ in }
    }
}
