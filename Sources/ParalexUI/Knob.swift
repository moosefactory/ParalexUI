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
    
    @State var style: KnobStyle
    
    var text: String?
    
    var title: String { text ?? style.label?.name ?? "" }
    
    private(set) var subText: String?
    
    private(set) var showSubtext: Bool?
    
    var symbolName: String?
    
    var titleFont: Font = Font.system(size: 12)
    var subTitleFont: Font = Font.system(size: 9)
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {
            if let symbol = symbolName, style.showIcon {
                Image(systemName: symbol)
            } else {
                Text(title).truncationMode(SwiftUI.Text.TruncationMode.tail).lineLimit(1)
            }
            if showSubtext == true, let subText = subText {
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
    var parameter: PXParameter? { get }
    var _parameterIdentifier: PXIdentifier? { get set }
}

extension ParameterKnobProtocol {
    public var identifier: PXIdentifier? { (parameter?.identifier ?? _parameterIdentifier) }

#if os(macOS)
    public var symbols: String? { parameter?.symbol }
#endif
    public var symbolNames: [String]? { parameter?.symbolNames }
    public var name: String? { parameter?.name }
}

public extension ParameterKnobProtocol {
    
    var title: String {

#if os(macOS)
        return knobStyle.titleOverride
        ?? parameter?.symbol
        ?? parameter?.name
        ?? identifier?.name
        ?? ""
#else
        return knobStyle.titleOverride
        ?? parameter?.name
        ?? identifier?.name
        ?? ""
#endif
        
        
    }
    
    var subTitle: String {
        return knobStyle.subtitleOverride
        ?? parameter?.name
        ?? identifier?.name
        ?? ""
    }
    
    var color: UniColor {
        return knobStyle.color ?? .blue
    }
}
