import SwiftUI
import ReversiLogics
import SwiftyReversi

struct ContentView: View {
    private let presenter: GamePresenter
    private let saver: Saver
    
    init() {
        saver = Saver()
        if let savedState = try? saver.load() {
            presenter = GamePresenter(savedState: savedState)
        } else {
            presenter = GamePresenter(manager: GameManager(game: Game(board: Board(width: 8, height: 8)), darkPlayer: .manual, lightPlayer: .manual))
        }
    }
    
    var body: some View {
        GameView(presenter: presenter)
            .environment(\.saver, saver)
    }
}
