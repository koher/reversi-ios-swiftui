import SwiftUI
import SwiftyReversi

struct ContentView: View {
    @State var game: Game = .init(board: Board(width: 8, height: 8))
    var body: some View {
        BoardView(game.board) { x, y in
            try? game.placeDiskAt(x: x, y: y)
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
