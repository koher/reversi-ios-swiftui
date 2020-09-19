import SwiftUI
import SwiftyReversi

struct DiskView: UIViewRepresentable {
    let disk: Disk
    
    init(_ disk: Disk) {
        self.disk = disk
    }
    
    func makeUIView(context: Context) -> _DiskView {
        let view = _DiskView()
        view.disk = disk
        return view
    }
    
    func updateUIView(_ uiView: _DiskView, context: Context) {
        uiView.disk = disk
    }
}
