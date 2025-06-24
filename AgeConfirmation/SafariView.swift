import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    var url: URL
    typealias UIViewControllerType = SFSafariViewController
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.barCollapsingEnabled = false
        let safariViewController = SFSafariViewController(url: url, configuration: config)
        return safariViewController
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
    }
}
