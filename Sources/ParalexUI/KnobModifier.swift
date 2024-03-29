//
//  KnobModifier.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 04/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI
import Paralex
import UniColor

public typealias PopoverIdentifier = PXIdentifier

//MARK: - Knob State

//MARK: - KnobStyle -

/// KnobState
///
/// Used internally by Knob objects to keep track of their state.

public struct KnobState {
    var enabled: Bool = true
    var pressed: Bool = false
    var selected: Bool = false
    var highlighted: Bool = false
    
    var isOn: Bool = false
}

//MARK: - KnobStyle -

/// KnobStyle
///
/// Used to pass style information to control
///
/// ParameterKnobs usually receive the color from the parameter factory
/// Passing a color in the KnobStyle overrides parameter color setting

public struct KnobStyle {
    public var label: PXLabel?
    public var color: UniColor?
    public var adapter: ValueAdapter?
    
    public var titleOverride: String?
    public var subtitleOverride: String?
    
    public var showSubtitle: Bool = true
    public var showIcon: Bool = true
    public var popoverIdentifier: PopoverIdentifier? = nil

    public init(label: PXLabel? = nil,
                color: UniColor? = nil,
                adapter: ValueAdapter? = nil,
                titleOverride: String? = nil,
                subtitleOverride: String? = nil,
                showSubtitle: Bool = true,
                showIcon: Bool = true,
                popoverIdentifier: PopoverIdentifier? = nil) {
        self.label = label
        self.color = color
        self.adapter = adapter
        self.titleOverride = titleOverride
        self.subtitleOverride = subtitleOverride
    
        self.showSubtitle = showSubtitle
        self.showIcon = showIcon
        self.popoverIdentifier = popoverIdentifier
    }
}

//MARK: - KnobModifier -

public struct KnobModifier: ViewModifier {

    public var color: UniColor = .blue

    @Binding public var state: KnobState

    public var animated: Bool = false

    // MARK: Getters
    
    var highlightedColor: UniColor { color.opacity(0.7) }
    var pressedColor: UniColor { color.opacity(0.8) }
    var fillColor: UniColor { color.opacity(0.2) }
    
    var computedColor: UniColor {
        var color = fillColor
        if state.pressed { color = pressedColor }
        if state.highlighted || state.isOn { color = highlightedColor }
        if !state.enabled {
            color = color.darken
        }
        return color
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: SwiftUI.RoundedCornerStyle.circular)
                .foregroundColor(computedColor.suiColor)
                .animation(.easeInOut(duration: animated ? 0.3: 0), value: computedColor)
            content
            if state.selected {
                    RoundedRectangle(cornerRadius: 5, style: SwiftUI.RoundedCornerStyle.circular)
                    .stroke(color.suiColor, lineWidth: 2)
                        .foregroundColor(.clear)
            }
        }
    }
}

struct KnobModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Test").modifier(KnobModifier(state: .constant(KnobState())))
    }
}
