import SwiftUI
import SwiftyReversi

struct ContentView: View {
    @State var disk: Disk = .dark
    var body: some View {
        CellView(disk: disk) {
            disk.flip()
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
