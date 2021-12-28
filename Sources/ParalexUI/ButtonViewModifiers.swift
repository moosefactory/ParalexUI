//
//  ButtonViewModifiers.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 02/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import Foundation
import SwiftUI

struct UIStandards {
    static let unit: Double = 32
    static let buttonHeight: Double = { unit }()
    static let controlsGap: Double = 8
    static let areasGap: Double = 8
    static let machineAreaHeight: Double = { unit * 2 }()
    static let controlsAreaHeight: Double = { unit * 1.7 }()
    static let formRowAreaHeight: Double = { unit * 1.2 }()
    
    static let squareSelectorSize = CGSize(width: unit, height: unit)
}

protocol MachineUIModifier {
    
}

struct StandardButton: ViewModifier, MachineUIModifier {
    func body(content: Content) -> some View {
        content
            .frame(minWidth: UIStandards.buttonHeight, idealWidth: 60, maxWidth: 220, idealHeight: UIStandards.buttonHeight)
        .layoutPriority(500)
    }
}

struct SquareFixedButton: ViewModifier, MachineUIModifier {
    func body(content: Content) -> some View {
        content
        .frame(minWidth: UIStandards.buttonHeight, idealWidth: UIStandards.buttonHeight, maxWidth: UIStandards.buttonHeight, minHeight: UIStandards.buttonHeight, idealHeight: UIStandards.buttonHeight, maxHeight: UIStandards.buttonHeight)
        .layoutPriority(1000)
    }
}

struct LongFixedButton: ViewModifier, MachineUIModifier {
    func body(content: Content) -> some View {
        content
        .frame(minWidth: 80, idealWidth: 80, maxWidth: 120, minHeight: UIStandards.buttonHeight, idealHeight: UIStandards.buttonHeight, maxHeight: UIStandards.buttonHeight)
    }
}


struct MediumFixedButton: ViewModifier, MachineUIModifier {
    func body(content: Content) -> some View {
        content
        .frame(minWidth: 64, idealWidth: 64, maxWidth: 90, minHeight: UIStandards.buttonHeight, idealHeight: UIStandards.buttonHeight, maxHeight: UIStandards.buttonHeight)
    }
}

struct SmallFixedButton: ViewModifier, MachineUIModifier {
    func body(content: Content) -> some View {
        content
        .frame(minWidth: 50, idealWidth: 50, maxWidth: 50, minHeight: UIStandards.buttonHeight, idealHeight: UIStandards.buttonHeight, maxHeight: UIStandards.buttonHeight)
        .layoutPriority(1000)
    }
}
