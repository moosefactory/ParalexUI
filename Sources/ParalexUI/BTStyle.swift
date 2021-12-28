//
//  BTStyle.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 29/11/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import Foundation
import UniColor
import SwiftUI

public extension Color {
    static let btRed = UniColor.red.suiColor
    static let btOrange = UniColor.orange.suiColor
    static let btYellow = UniColor.yellow.suiColor
    static let btGreen = UniColor.green.suiColor
    static let btCyan = UniColor.cyan.suiColor
    static let btBlue = UniColor.blue.suiColor
    static let btPurple = UniColor.purple.suiColor
    static let btPink = UniColor.pink.suiColor
    static let btMint = UniColor.mint.suiColor
    static let btBrown = UniColor.brown.suiColor
    static let btBlack = UniColor.black.suiColor
    static let btWhite = UniColor.white.suiColor
    static let btDarkGray = UniColor.darkGray.suiColor
    static let btLightGray = UniColor.lightGray.suiColor
}

public struct BTPalette {
    static let white = CGColor.make(with: "#fffffe")
    static let black = CGColor.make(with: "#010000")

    static let blue = CGColor.make(with: "#436afe")
    static let red = CGColor.make(with: "#fd3f40")
    static let green = CGColor.make(with: "#2bcb34")
    static let orange = CGColor.make(with: "#fdaf40")
    static let yellow = CGColor.make(with: "#fce44f")

    static let darkGray = CGColor.make(with: "#111110")
    static let lightGray = CGColor.make(with: "#eeeeed")

    static let machineButtonColor = CGColor.make(with: "#dddfef")

    static let intent = CGColor.make(with: "#fdaf40")

    static let soloYellow = CGColor.make(with: "#fce44f")
    static let muteBlue = CGColor.make(with: "#436afe")
    
    static func cgColor(at index: Int) -> CGColor {
        return BTPalette.pickerColors[
            max(min(index, BTPalette.pickerColors.count - 1),0)
        ].cgColor
    }
    
    static var pickerColors: [UniColor] =
    [.red, .orange, .yellow, .green, .blue, .cyan, .purple, .pink, .brown, .black, .darkGray, .lightGray, .white]
}
