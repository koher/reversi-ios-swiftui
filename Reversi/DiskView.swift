import SwiftUI
import SwiftyReversi

struct DiskView: View {
    let disk: Disk
    
    init(_ disk: Disk) {
        self.disk = disk
    }
    
    var body: some View {
        Circle()
            .foregroundColor(disk.color)
    }
}

private extension Disk {
    var color: Color {
        switch self {
        case .dark: return Color("DarkColor")
        case .light: return Color("LightColor")
        }
    }
}

struct DiskView_Previews: PreviewProvider {
    static var previews: some View {
        DiskView(.dark)
    }
}
