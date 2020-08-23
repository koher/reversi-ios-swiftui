import SwiftUI
import ReversiLogics
import SwiftyReversi

struct ContentView: View {
    @State var gamePresenter: GamePresenter = .init(
        manager: GameManager(
            game: Game(),
            darkPlayer: .manual,
            lightPlayer: .manual
        )
    )
    
    var body: some View {
        GameView(presenter: $gamePresenter)
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
