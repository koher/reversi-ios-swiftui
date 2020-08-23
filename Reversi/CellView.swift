import SwiftUI
import SwiftyReversi

// TODO: Implement appropriate animations.
struct CellView: View {
    let disk: Disk?
    let action: () -> Void
    
    init(disk: Disk?, action: @escaping () -> Void) {
        self.disk = disk
        self.action = action
    }
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: action, label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(Color("CellColor"))
                    if let disk = disk {
                        DiskView(disk)
                            .animation(.linear(duration: 0.25))
                            .frame(
                                maxWidth: geometry.size.width * 0.8,
                                maxHeight: geometry.size.height * 0.8
                            )
                            
                    }
                }
            })
        }
    }
}

struct CellView_Previews: PreviewProvider {
    static var previews: some View {
        CellView(disk: .dark) {}
    }
}
