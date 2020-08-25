import SwiftUI
import SwiftyReversi
import ReversiLogics

struct GameView: View {
    @Binding var presenter: GamePresenter
    
    init(presenter: Binding<GamePresenter>) {
        self._presenter = presenter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            MessageView(presenter.message)
            Spacer()
            HStack(spacing: 16) {
                DiskView(.light)
                    .frame(width: 26, height: 26)
                PlayerPicker(selection: $presenter.lightPlayer)
                    .frame(width: 161)
                Text(presenter.count(of: .light).description)
                    .font(.system(size: 24))
                if presenter.isPlayerActivityIndicatorVisible(of: .light) {
                    ProgressView()
                }
                Spacer()
            }
            BoardView(presenter.manager.game.board) { x, y in
                presenter.tryPlacingDiskAt(x: x, y: y)
            } animationCompletion: {
                presenter.completePlacingDisks()
            }
            HStack(spacing: 16) {
                Spacer()
                if presenter.isPlayerActivityIndicatorVisible(of: .dark) {
                    ProgressView()
                }
                Text(presenter.count(of: .dark).description)
                    .font(.system(size: 24))
                PlayerPicker(selection: $presenter.darkPlayer)
                    .frame(width: 161)
                DiskView(.dark)
                    .frame(width: 26, height: 26)
            }
            Spacer()
            Button("Reset") {
                presenter.confirmToReset()
            }
            .alert(isPresented: .constant(presenter.isResetAlertVisible)) {
                Alert(
                    title: Text("Confirmation"),
                    message: Text("Do you really want to reset the game?"),
                    primaryButton: .cancel(Text("Cancel")) {
                        presenter.completeConfirmationForReset(false)
                    },
                    secondaryButton: .destructive(Text("OK")) {
                        presenter.completeConfirmationForReset(true)
                    }
                )
            }
        }
        .padding(20)
        .alert(isPresented: .constant(presenter.isPassingAlertVisible)) {
            Alert(
                title: Text("Pass"),
                message: Text("Cannot place a disk."),
                dismissButton: .default(Text("Dismiss")) {
                    presenter.completeConfirmationForPass()
                }
            )
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
        manager: GameManager(
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