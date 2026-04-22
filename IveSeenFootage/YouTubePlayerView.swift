import SwiftUI
import WebKit

struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    let startTime: Int
    let endTime: Int
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedURL = "https://www.youtube.com/embed/\(videoID)?start=\(startTime)&end=\(endTime)&playsinline=1&autoplay=1"
        
        if let url = URL(string: embedURL) {
            var request = URLRequest(url: url)
                        request.setValue("https://myapp.local", forHTTPHeaderField: "Referer")
            
            uiView.load(request)
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Jordan Tyson Prototype")
                .font(.title)
                .bold()
            
            YouTubePlayerView(videoID: "pULZVS4U3OI", startTime: 8, endTime: 15)
                .frame(height: 250)
                .cornerRadius(12)
                .shadow(radius: 5)
                .padding(.horizontal)
            
            Text("Play Result: 15 yd Reception")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    ContentView()
}
