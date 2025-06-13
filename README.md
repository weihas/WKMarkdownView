# WKMarkdownView

A lightweight Swift component for rendering **Markdown** and **KaTeX math** inside a `WKWebView`, all using **local resources**.

---

## ✨ Features

- ✅ Render Markdown via [marked.js](https://github.com/markedjs/marked)
- ✅ Support for inline and block LaTeX using [KaTeX](https://katex.org/)
- ✅ Light/Dark mode via `prefers-color-scheme`
- ✅ Async Swift API using `async/await`
- ✅ Get dynamic content height for layout
- ✅ Local resource loading, no internet required

---

## 📝 Requirements

- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

---

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/weihas/WKMarkdownView.git", from: "1.0.0")
]
```

## 🚀 Usage

### Basic Usage

```swift
import WKMarkdownView

// Create a markdown view with KaTeX support
let markdownView = WKMarkdownView(enableLatex: true)
view.addSubview(markdownView)
markdownView.frame = view.bounds

// Update markdown content
Task {
    try? await markdownView.updateMarkdown("""
    # Hello World
    
    This is **Markdown** with math support:
    
    Inline math: $E = mc^2$
    
    Block math:
    $$
    \\frac{a}{b} = c
    $$
    """)
}
```

### Get Content Height

```swift
Task {
    let height = try? await markdownView.contentHeight()
    // Use height for layout calculations
}
```

### Disable KaTeX

```swift
// Create a markdown view without math support
let markdownView = WKMarkdownView(enableLatex: false)
```

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/WKMarkdownView/issues).
