import SwiftUI
import WebKit

// 1. Wrap the WebKit view for SwiftUI
struct YouTubePlayerView: UIViewRepresentable {
    let videoID: String
    let startTime: Int
    let endTime: Int
    
    func makeUIView(context: Context) -> WKWebView {
        // Crucial: Tell iOS to allow the video to play inside your app's layout
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.isScrollEnabled = false // Hides the web page scrolling
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let embedURL = "https://www.youtube.com/embed/\(videoID)?start=\(startTime)&end=\(endTime)&playsinline=1&autoplay=1"
        
        if let url = URL(string: embedURL) {
            // 1. Change from a constant URLRequest to a variable so we can edit it
            var request = URLRequest(url: url)
            
            // 2. THE FIX: Inject a valid Referer header to bypass YouTube's block
            request.setValue("https://myapp.local", forHTTPHeaderField: "Referer")
            
            uiView.load(request)
        }
    }
}

// 3. Your Main App Screen
struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Jordan Tyson Prototype")
                .font(.title)
                .bold()
            
            // Just drop in a video ID from a Big 12 highlight reel
            // Example: "dQw4w9WgXcQ"
            YouTubePlayerView(videoID: "pULZVS4U3OI", startTime: 8, endTime: 15)
                .frame(height: 250) // Force it into a nice landscape box
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
