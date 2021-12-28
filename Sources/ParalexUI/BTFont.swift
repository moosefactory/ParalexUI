//
//  BTFont.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 01/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import Foundation
import SwiftUI

struct BTFont {
    
    public struct StyleSize: Equatable {
        var identifier: String
        var textSize: CGFloat

        init(identifier: String,textSize: CGFloat = 13) {
            self.identifier = identifier
            self.textSize = textSize
        }
        
        public static let tiny = StyleSize(identifier: "tiny", textSize: 10)
        public static let small = StyleSize(identifier: "small", textSize: 12)
        public static let normal = StyleSize(identifier: "normal", textSize: 14)
        
        public static let medium = StyleSize(identifier: "medium", textSize: 16)
        
        public static let large = StyleSize(identifier: "large", textSize: 18)
        public static let larger = StyleSize(identifier: "larger", textSize: 20)
        public static let huge = StyleSize(identifier: "huge", textSize: 22)

        public static func == (lhs: StyleSize, rhs: StyleSize) -> Bool {
            return lhs.identifier == rhs.identifier
        }
    }

    public static let fontName = "DIN"
    public static let fontNameBold = "DINCondensed-Bold"
    public static let fontSize: CGFloat = 4
    
    public static let segmentsFontName = "Open 24 Display St"
    public static let dotsFontName = "Score Board"

    
    public static let systemFont: Bool = true
    
    public static func font(for size: StyleSize) -> Font {
        if systemFont {
            return Font.system(size: size.textSize)
        }
        return Font(CTFontCreateWithName(fontName as CFString, size.textSize, nil))
    }
    
    public static func dotsFont(for size: StyleSize) -> Font {
        return Font(CTFontCreateWithName(dotsFontName as CFString, size.textSize, nil))
    }

    static let tiny = BTFont.font(for: StyleSize.tiny)
    static let small = BTFont.font(for: StyleSize.small)
    static let normal = BTFont.font(for: StyleSize.normal)
    static let medium = BTFont.font(for: StyleSize.medium)
    static let large = BTFont.font(for: StyleSize.large)
    static let larger = BTFont.font(for: StyleSize.larger)
    static let huge = BTFont.font(for: StyleSize.huge)
}
