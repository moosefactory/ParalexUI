//
//  Knob.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 04/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI
import Paralex

//MARK: - AnyParameter Handle

struct KnobCell: View {
    
    private(set) var text: String
    private(set) var subText: String
    
    private(set) var showSubtext: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 1) {

            if true {
                Text(text).font(BTFont.normal).truncationMode(SwiftUI.Text.TruncationMode.tail).lineLimit(1)
                if showSubtext  {
                    Text(subText).font(BTFont.tiny).opacity(0.5).truncationMode(SwiftUI.Text.TruncationMode.tail).lineLimit(1)
                }
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
    var parameterNode: ParameterGraphNode { get }
}

extension ParameterKnobProtocol {
    public var identifier: Identifier { parameterNode.identifier }
    public var parameter: Parameter? { parameterNode.parameter }
    public var symbols: String? { parameterNode.symbol }
    public var name: String? { parameterNode.name }
}

public extension ParameterKnobProtocol {
    
    var title: String {
        return knobStyle.titleOverride
        ?? parameterNode.symbol
        ?? parameterNode.name
        ?? parameterNode.slug
    }
    
    var subTitle: String {
        return knobStyle.subtitleOverride
        ?? parameterNode.name
        ?? identifier.name
        ?? parameterNode.slug
    }
    
    var color: Color {
        return knobStyle.color?.suiColor ?? .blue
    }
}
