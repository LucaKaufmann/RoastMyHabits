import SwiftUI

enum DesignTokens {
    enum Colors {
        static let background = Color.black
        static let foreground = Color.white
        static let accentPrimary = Color(.sRGB, red: 0.224, green: 1.0, blue: 0.078, opacity: 1.0)
        static let accentSecondary = Color(.sRGB, red: 1.0, green: 0.271, blue: 0.0, opacity: 1.0)
        static let muted = Color(.sRGB, red: 0.36, green: 0.36, blue: 0.36, opacity: 1.0)
    }

    enum Typography {
        static let hero = Font.system(size: 72, weight: .black)
        static let section = Font.system(size: 32, weight: .black)
        static let title = Font.system(size: 24, weight: .black)
        static let body = Font.system(size: 17, weight: .bold)
        static let caption = Font.system(size: 12, weight: .semibold)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum Border {
        static let regular: CGFloat = 2
        static let heavy: CGFloat = 3
    }

    enum Animation {
        static let rigid = SwiftUI.Animation.easeOut(duration: 0.15)
        static let overlay = SwiftUI.Animation.spring(duration: 0.2, bounce: 0)
    }
}
