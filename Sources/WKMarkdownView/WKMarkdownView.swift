//
//  WKMarkdownView.swift
//  WKMarkdownView
//
//  Created by WeIHa'S on 2025/6/6.
//

import Foundation
import WebKit

/// A custom WKWebView subclass used to render Markdown content,
/// with optional KaTeX math rendering support.
public class WKMarkdownView: WKWebView {
    
    /// The markdown string to be rendered
    public private(set) var markdown: String = ""
    
    /// Whether to enable KaTeX rendering
    public var enableLatex: Bool = true
    
    /// Used to notify when the index.html has finished loading
    private var loadContinuation: CheckedContinuation<Void, Never>?
    
    /// A task that loads the initial HTML template only once
    private var loadingTask: Task<Void, Error>?
    
    /// Designated convenience initializer to create a WKMarkdownView with math rendering enabled or disabled
    public convenience init(enableLatex: Bool) {
        let config = WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        self.enableLatex = enableLatex
    }
    
    /// Designated convenience initializer to create a WKMarkdownView with math rendering enabled or disabled
    public convenience init(markdown: String, enableLatex: Bool = true) {
        let config = WKWebViewConfiguration()
        self.init(frame: .zero, configuration: config)
        self.enableLatex = enableLatex
        Task { try await updateMarkdown(markdown) }
    }
    
    /// Designated initializer for WKMarkdownView
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.navigationDelegate = self
        isOpaque = false // Make background transparent
        backgroundColor = .clear
        
        // Start loading local index.html from bundle
        loadingTask = Task {
            try await loadIndexHTML()
            loadingTask = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Loads the local HTML file `index.html` into the webview.
    private func loadIndexHTML() async throws {
        await withCheckedContinuation { continuation in
            self.loadContinuation = continuation
            
            // Ensure the index.html exists in the resource bundle
            guard let indexURL = Bundle.module.url(forResource: "index", withExtension: "html") else {
                assertionFailure("Missing index.html in bundle")
                continuation.resume()
                return
            }
            
            // Load local HTML with read access to its directory
            loadFileURL(indexURL, allowingReadAccessTo: indexURL.deletingLastPathComponent())
        }
    }
    
    /// Ensures JavaScript evaluation happens after `index.html` has been loaded
    @discardableResult
    open override func evaluateJavaScript(_ javaScriptString: String) async throws -> Any? {
        try await loadingTask?.value
        return try await super.evaluateJavaScript(javaScriptString)
    }
    
    /// Updates the rendered markdown by injecting it into the webview using JavaScript
    /// - Parameter newMarkdown: The markdown string to be rendered
    public func updateMarkdown(_ newMarkdown: String) async throws {
        self.markdown = newMarkdown
        
        // Escape markdown safely for JavaScript string injection
        let escaped = try escapedMarkdown(context: newMarkdown)
        
        // Inject JavaScript call to render markdown with enableLatex flag
        let js = "renderMarkdown(\(escaped), \(enableLatex ? "true" : "false"));"
        try await evaluateJavaScript(js)
    }
    
    /// Escapes markdown string by serializing it to JSON, ensuring proper escaping for JavaScript injection
    private func escapedMarkdown(context: String) throws -> String {
        let jsonEncoded = try JSONSerialization.data(withJSONObject: [context])
        let jsonString = String(data: jsonEncoded, encoding: .utf8)!
        // Remove the surrounding square brackets from the array JSON
        return String(jsonString.dropFirst().dropLast())
    }
    
    /// Returns the rendered content height of the markdown inside the webview
    public func contentHeight() async throws -> Double {
        guard try await evaluateJavaScript("document.readyState") != nil,
              let height = try await evaluateJavaScript("document.body.scrollHeight") as? Double else {
            return 0
        }
        return height
    }
}

// MARK: - WKNavigationDelegate
extension WKMarkdownView: WKNavigationDelegate {
    
    /// Called when webview finishes loading index.html, resumes the load continuation
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let continuation = loadContinuation {
            loadContinuation = nil
            continuation.resume()
        }
    }
}






@available(iOS 17.0, *)
#Preview {
    let sampleMarkdown =
"""
### The quadratic formula:

$$x = \\frac{-b \\pm \\sqrt{b^2 - 4ac}}{2a}$$

Inline example: \\( \\sin^2 \\theta + \\cos^2 \\theta = 1 \\)

### Matrix & Determinant
$$ 
A = \\begin{bmatrix}
1 & 2 & 3 \\\\
4 & 5 & 6 \\\\
7 & 8 & 9
\\end{bmatrix}
$$

The formula for calculating the determinant is as follows:
$$
\\text{det}(A) = 1(5 \\cdot 9 - 6 \\cdot 8) - 2(4 \\cdot 9 - 6 \\cdot 7) + 3(4 \\cdot 8 - 5 \\cdot 7)
$$

### Complex formulas

$$ \\frac{d^n}{dx^n} e^{ax} \\sin(bx) = (a^2 + b^2)^{n/2} e^{ax} \\sin\\left(bx + n \\arctan\\frac{b}{a}\\right) $$
"""
    
    return WKMarkdownView(markdown: sampleMarkdown, enableLatex: true)
}
