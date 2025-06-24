# WKMarkdownView

[![Swift Version](https://img.shields.io/badge/Swift-5.5%2B-orange)](https://swift.org) [![Platforms](https://img.shields.io/badge/platform-iOS%2013%2B-blue)](https://www.apple.com/ios/) [![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/) [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A lightweight Swift component for rendering **Markdown** and **KaTeX math** inside a `WKWebView`, all using **local resources**.

---

## Features

- ✅ Render Markdown via [marked.js](https://github.com/markedjs/marked)
- ✅ Support for inline and block LaTeX using [KaTeX](https://katex.org/)
- ✅ Light/Dark mode via `prefers-color-scheme`
- ✅ Modern async Swift API using `async/await`
- ✅ Dynamically get content height for flexible layouts
- ✅ Fully offline: all resources are bundled locally
- ✅ **SwiftUI support** with automatic height adjustment

---

## Requirements

- iOS 13.0+
- Swift 5.5+
- Xcode 13.0+

---

## Installation

### Swift Package Manager

To install `WKMarkdownView` using the [Swift Package Manager](https://swift.org/package-manager/), add it to the `dependencies` in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/weihas/WKMarkdownView.git", from: "1.0.0")
]
```

---

## Quick Start

`WKMarkdownView` offers a native SwiftUI view that automatically handles rendering and resizing. This is the easiest way to get started.

```swift
import WKMarkdownView
import SwiftUI

struct ContentView: View {
    let markdown = """
    # Welcome to SwiftUI

    This is **Markdown** rendered in SwiftUI.

    You can also write math: $E = mc^2$.

    $$
    \\int_a^b f(x) \\, dx
    $$
    """

    var body: some View {
        ScrollView {
            MarkdownView(markdown)
                .padding()
        }
    }
}
```

## Advanced Usage

### UIKit Integration

You can also use `WKMarkdownView` directly in a UIKit project.

```swift
import WKMarkdownView

// 1. Create a markdown view instance
// LaTeX support is enabled by default
let markdownView = WKMarkdownView() 
view.addSubview(markdownView)

// 2. Set its frame
markdownView.frame = view.bounds
markdownView.autoresizingMask = [.width, .height]

// 3. Load the markdown content
Task {
    try? await markdownView.updateMarkdown("""
    # Hello from UIKit
    
    This is **Markdown** with math support:
    
    Inline math: $E = mc^2$
    
    Block math:
    $$
    \\frac{a}{b} = c
    $$
    """)
}
```

### Getting Content Height

For manual layout calculations, you can asynchronously retrieve the rendered content's height.

```swift
Task {
    if let height = try? await markdownView.contentHeight() {
        // Use the height for your layout...
        print("Content height: \\(height)")
    }
}
```

### Disabling LaTeX Support

If you don't need math rendering, you can disable it during initialization to save resources.

```swift
// Create a markdown view without LaTeX/math support
let markdownView = WKMarkdownView(enableLatex: false)
```

---

## Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/weihas/WKMarkdownView/issues).

---

## License

`WKMarkdownView` is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
