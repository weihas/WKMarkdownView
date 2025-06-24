//
//  MarkdownWebView.swift
//  WKMarkdownView
//
//  Created by WeIHa'S on 2025/6/20.
//

import SwiftUI
import WebKit

/// A SwiftUI view that renders Markdown content and automatically adjusts its height
public struct MarkdownView: View {
    /// The Markdown string to render
    var markdown: String

    /// The calculated height of the content, updated dynamically
    @State private var contentHeight: CGFloat = 0

    /// Initializes the Markdown view with given content
    /// - Parameter markdown: A string containing Markdown-formatted text
    public init(_ markdown: String) {
        self.markdown = markdown
    }

    /// The view body that embeds the underlying UIKit-based web view
    public var body: some View {
        MarkdownWebView(markdown: markdown, contentHeight: $contentHeight)
            .frame(height: contentHeight) // Adjust frame height based on content
    }
}

/// A UIViewRepresentable wrapper for a WKWebView-based Markdown renderer
struct MarkdownWebView: UIViewRepresentable {
    /// The Markdown string to render
    let markdown: String

    /// A binding to the dynamic height of the content
    @Binding var contentHeight: CGFloat

    /// Creates the UIKit view (WKMarkdownView) to be used in SwiftUI
    func makeUIView(context: Context) -> WKMarkdownView {
        let configuration = WKWebViewConfiguration()
        let markdownView = WKMarkdownView(frame: .zero, configuration: configuration)
        markdownView.scrollView.isScrollEnabled = false // Disable internal scrolling
        markdownView.backgroundColor = .clear
        return markdownView
    }

    /// Updates the view when SwiftUI state changes
    func updateUIView(_ webView: WKMarkdownView, context: Context) {
        Task {
            do {
                // Load the new markdown content asynchronously
                try await webView.updateMarkdown(markdown)
                // Measure and update the content height
                contentHeight = try await webView.contentHeight()
            } catch {
                print(error) // Handle rendering or layout errors
            }
        }
    }
}


#Preview {
    MarkdownView(
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
    )
}
