import SwiftUI
import SwiftyReversi
import ReversiLogics

struct GameView: View {
    @Environment(\.computer) private var computer: Computer
    @Environment(\.saver) private var saver: Saver
    @State var presenter: GamePresenter
    
    var body: some View {
        try? saver.save(presenter.savedState)
        if let board = presenter.boardForComputer {
            computer.move(for: board) { x, y in
                presenter.placeDiskAt(x: x, y: y)
            }
        } else {
            computer.cancel()
        }

        return VStack(spacing: 20) {
            MessageView(presenter.message)
            Spacer()
            PlayerStateView(
                side: .dark,
                count: presenter.count(of: .dark),
                player: $presenter.darkPlayer,
                isActivityIndicatorVisible: presenter.isPlayerActivityIndicatorVisible(of: .dark)
            )
                .environment(\.layoutDirection, .leftToRight)
            BoardView(presenter.manager.game.board, action: { x, y in
                presenter.tryPlacingDiskAt(x: x, y: y)
            }, animationCompletion: presenter.needsAnimatingBoardChanges ? {
                presenter.completeFlippingDisks()
            } : nil)
                .aspectRatio(1, contentMode: .fit)
            PlayerStateView(
                side: .light,
                count: presenter.count(of: .light),
                player: $presenter.lightPlayer,
                isActivityIndicatorVisible: presenter.isPlayerActivityIndicatorVisible(of: .light)
            )
                .environment(\.layoutDirection, .rightToLeft)
            Spacer()
            Button("Reset") {
                presenter.confirmToReset()
            }
        }
        .padding(20)
        .alert(isPresented: .constant(presenter.isResetAlertVisible || presenter.isPassingAlertVisible)) {
            if presenter.isResetAlertVisible {
                return Alert(
                    title: Text("Confirmation"),
                    message: Text("Do you really want to reset the game?"),
                    primaryButton: .cancel(Text("Cancel")) {
                        presenter.reset(false)
                    },
                    secondaryButton: .destructive(Text("OK")) {
                        presenter.reset(true)
                    }
                )
            } else if presenter.isPassingAlertVisible {
                return Alert(
                    title: Text("Pass"),
                    message: Text("Cannot place a disk."),
                    dismissButton: .default(Text("Dismiss")) {
                        presenter.pass()
                    }
                )
            } else {
                preconditionFailure("Never reaches here.")
            }
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
    struct PlayerStateView: View {
        let side: Disk
        let count: Int
        @Binding var player: Player
        let isActivityIndicatorVisible: Bool
        
        var body: some View {
            HStack(spacing: 16) {
                DiskView(side)
                    .frame(width: 26, height: 26)
                PlayerPicker(selection: $player)
                    .frame(width: 161)
                    .environment(\.layoutDirection, .leftToRight)
                Text(count.description)
                    .font(.system(size: 24))
                if isActivityIndicatorVisible {
                    ProgressView()
                }
                Spacer()
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
