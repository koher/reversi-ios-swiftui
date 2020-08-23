import SwiftUI
import SwiftyReversi
import ReversiLogics

struct GameView: View {
    @Binding var presenter: GamePresenter
    
    // FIXME: Replace them with `presenter`'s properties
    @State var darkPlayer: Player = .manual
    @State var lightPlayer: Player = .manual

    init(presenter: Binding<GamePresenter>) {
        self._presenter = presenter
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                MessageView(presenter.message)
                Spacer()
                HStack(spacing: 16) {
                    DiskView(.light)
                        .frame(width: 26, height: 26)
                    PlayerPicker(selection: $lightPlayer)
                    Text(presenter.count(of: .light).description)
                        .font(.system(size: 24))
                    if presenter.isPlayerActivityIndicatorVisible(of: .light) {
                        ProgressView()
                    }
                    Spacer()
                }
                BoardView(presenter.gameManager.game.board) { x, y in
                    // TODO
                }
                HStack(spacing: 16) {
                    Spacer()
                    if presenter.isPlayerActivityIndicatorVisible(of: .dark) {
                        ProgressView()
                    }
                    Text(presenter.count(of: .dark).description)
                        .font(.system(size: 24))
                    PlayerPicker(selection: $darkPlayer)
                    DiskView(.dark)
                        .frame(width: 26, height: 26)
                }
                Spacer()
                Button("Reset") {
                    // TODO
                }
            }
                .padding(20)
        }
    }
}

extension GameView {
    struct MessageView: View {
        let message: GamePresenter.Message
        
        init(_ message: GamePresenter.Message) {
            self.message = message
        }
        
        var body: some View {
            HStack {
                switch message {
                case .turn(let side):
                    DiskView(side)
                        .frame(width: 24, height: 24)
                    Text("'s turn")
                        .font(.system(size: 32))
                case .result(.some(let side)):
                    DiskView(side)
                        .frame(width: 24, height: 24)
                    Text("won")
                        .font(.system(size: 32))
                case .result(.none):
                    Text("Tied")
                        .font(.system(size: 32))
                }
            }
        }
    }
}

extension GameView {
    struct PlayerPicker: View {
        @Binding var selection: Player
        
        var body: some View {
            Picker(selection: $selection, label: EmptyView(), content: {
                Text("Manual").tag(Player.manual)
                Text("Computer").tag(Player.computer)
            })
                .pickerStyle(SegmentedPickerStyle())
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var presenter: GamePresenter = .init(
        gameManager: GameManager(
            game: Game(),
            darkPlayer: .manual,
            lightPlayer: .manual
        )
    )
    
    static var previews: some View {
        GameView(
            presenter: Binding(
                get: { presenter },
                set: { newValue in presenter = newValue }
            )
        )
    }
}
