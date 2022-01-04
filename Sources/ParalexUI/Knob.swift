//
//  Knob.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 04/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI
import Paralex
import UniColor

//MARK: - AnyParameter Handle

struct KnobCell: View {
    
    private(set) var text: String
    private(set) var subText: String
    
    private(set) var showSubtext: Bool

    private(set) var symbolName: String?

    var titleFont: Font = Font.system(size: 12)
    var subTitleFont: Font = Font.system(size: 9)
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            if let symbol = symbolName {
                Image(systemName: symbol)
            } else {
                Text(text).truncationMode(SwiftUI.Text.TruncationMode.tail).lineLimit(1)
            }
            if showSubtext  {
                Text(subText).font(subTitleFont).opacity(0.5).truncationMode(SwiftUI.Text.TruncationMode.tail).lineLimit(1)
            }
        }.fixedSize(horizontal: false, vertical: true)
    }
}

//MARK: - Knob Protocol -

public protocol KnobProtocol {
    var knobState: KnobState { get set }
    var knobStyle: KnobStyle { get set }
}


//MARK: - Knob Event

enum KnobEventType {
    case tap
    case drag
}

enum KnobEventPhase {
    case started
    case changed
    case ended
}

public struct KnobEvent {
    var type: KnobEventType
    var modifiers: EventModifiers = []
    var phase: KnobEventPhase = .started
    var value: Double = 0
}

extension KnobEvent {
    var commandDown: Bool { modifiers.contains(.command) }
    var controlDown: Bool { modifiers.contains(.control) }
}

//MARK: - AnyParameter Knob Protocol -

public protocol ParameterKnobProtocol: KnobProtocol {
    var parameter: PXParameter { get }
}

extension ParameterKnobProtocol {
    public var identifier: PXIdentifier { parameter.identifier }
    #if os(macOS)
    public var symbols: String? { parameter.symbol }
    #endif
    public var symbolNames: [String]? { parameter.symbolNames }
    public var name: String? { parameter.name }
}

public extension ParameterKnobProtocol {
    
    var title: String {
        var sfSymbol: String? = nil
#if os(macOS)
var sfSymbol = parameter.symbol
#endif

        return knobStyle.titleOverride
        ?? sfSymbol
        ?? parameter.name
    }
    
    var subTitle: String {
        return knobStyle.subtitleOverride
        ?? parameter.name
    }
    
    var color: UniColor {
        return knobStyle.color ?? .blue
    }
}
