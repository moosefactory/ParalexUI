//
//  KnobButton.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 04/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI
import Paralex
import Combine

public struct KnobButton: View, ParameterKnobProtocol {
    
    //@EnvironmentObject var context: PXContext?
    
    // MARK: - Properties
    
    // MachineViewProtocol
    //    @EnvironmentObject var machineController: MachineController
    
    // MARK: - State Properties
    
    // ParameterHandleBox Protocol
    @State public var parameter: PXParameter?
    
    var parameterIdentifier: PXIdentifier {
        return (parameter?.identifier ?? _parameterIdentifier)!
    }
    
    @State public var _parameterIdentifier: PXIdentifier?
    
    // Knob Protocol
    @State public var knobState = KnobState()
    
    // Display Name
    @State public var displayedValue: String = "-"
    
    // Private Properties
    @State private var onPublisherListener: AnyCancellable?
    
    // If button edits a model, the binding is made here
    // Button can also be only an indicator by listening to the 'isOn' publisher
    var isOnBinding: (Binding<Bool>)?
    
    /// isOn
    var isOnPublisher: AnyPublisher<Bool, Never>?

    // MARK: - State Properties
    
    /// knobStyle
    @State public var knobStyle = KnobStyle()
    
    /// isToggle
    @State public var isToggle: Bool = false
    
    /// stateSource
    ///
    /// If a state source is set, then the state of the button is controled by an external value
    var stateSource: PXParameter?
    
    /// The condition that will make this button highlighted
    /// Default is when value is grater than zero
    var stateOnCondition: ((Double)->Bool)?
    
    /// action
    var action: ((KnobEvent)->Void)?
    
    
    // MARK: - Initialization
    
    public init(parameter: PXParameter,
                knobStyle: KnobStyle = KnobStyle(showIcon: true),
                action: ((KnobEvent)->Void)? = nil) {
        _parameter = State(wrappedValue: parameter)
        _knobStyle = State(initialValue: knobStyle)
        self.action = action
    }

    public init(parameter: PXParameter,
                isOnPublisher: ( AnyPublisher<Bool, Never>?),
                stateOnCondition: ((Double)->Bool)? = { $0 > 0 },
                knobStyle: KnobStyle = KnobStyle(showIcon: true),
                action: ((KnobEvent)->Void)? = nil) {
        _parameter = State(wrappedValue: parameter)
        _knobStyle = State(initialValue: knobStyle)
        self.isOnPublisher = isOnPublisher
        self.stateOnCondition = stateOnCondition
        self.action = action
    }
    
    public init(parameter: PXParameter,
                isOnBinding: Binding<Bool>,
                stateOnCondition: ((Double)->Bool)? = { $0 > 0 },
                knobStyle: KnobStyle = KnobStyle(showIcon: true),
                action: ((KnobEvent)->Void)? = nil) {
        _parameter = State(wrappedValue: parameter)
        _knobStyle = State(initialValue: knobStyle)
        self.isOnBinding = isOnBinding
        self.stateOnCondition = stateOnCondition
        self.action = action
    }
    
    public init(identifier: PXIdentifier,
                stateSource: PXParameter? = nil,
                stateOnCondition: ((Double)->Bool)? = { $0 > 0 },
                knobStyle: KnobStyle = KnobStyle(showIcon: true),
                action: ((KnobEvent)->Void)? = nil) {
        __parameterIdentifier = State(wrappedValue: identifier)
        displayedValue = identifier.displayName
        _knobStyle = State(initialValue: knobStyle)
        self.stateSource = stateSource
        self.stateOnCondition = stateOnCondition
        self.action = action
    }

    // MARK: - Body
    
    public var body: some View {
        
        ZStack {
            if let parameter = parameter {
                KnobCell(style: knobStyle, text: displayedValue,
                         subText: subTitle,
                         showSubtext: knobStyle.showSubtitle,
                         symbolName: parameter.symbolName)
                    .onReceive(parameter.$doubleValue) { value in
                        print("[KnobButton] AnyParameter \(parameter.identifier) Change")
                    }
                    .onAppear() {
                        displayedValue = title
                    }
            } else {
                KnobCell(style: knobStyle)
            }
            
            // If Knob is enabled, we add the tap gesture
            
            if knobState.enabled {
                let tap = KnobTapModifier(mouseDragIn: $knobState.highlighted,
                                          mouseDragWithCommandIn: $knobState.selected) { event in
                    print("[KnobButton.tap \(parameter?.log ?? parameterIdentifier.rawValue)")
                    if !event.commandDown {
                        if let param = parameter, param.role == .command {
                            param.valueDidChangeClosure?(param)
                        }
                        if parameter?.type == .bool {
                            if let boolValue = parameter?.bool {
                                parameter?.bool = !boolValue
                            }
                        } else {
                            //parameter.apply(value: 1)
                        }
                    } else {
                        //mc.parametersSelection.toggle(parameter)
                    }
                    
                    if let isOnBinding = isOnBinding {
                        isOnBinding.wrappedValue = !isOnBinding.wrappedValue
                        knobState.isOn = isOnBinding.wrappedValue
                    }
                    
                    action?(KnobEvent(type: .tap, modifiers: [], phase: .ended, value: parameter?.doubleValue ?? 0))
                }
                Rectangle().foregroundColor(.white.opacity(0.001))
                    .modifier(tap)
            }
            
            // If we have a toggle and isOn source is not an external parameter,
            // we subscribe to the parameter to update isOn state when parameter value is changed
            
            
                if let isOnPublisher = isOnPublisher {
                    Rectangle().foregroundColor(.clear)
                    .onReceive(isOnPublisher) { value in
                        knobState.isOn = value
                        knobState.highlighted = knobState.isOn
                    }
                } else if let stateSource = stateSource ?? parameter {
                    Rectangle().foregroundColor(.clear)
                        .onChange(of: stateSource.doubleValue) { value in
                            knobState.isOn = stateOnCondition?(value) ?? parameter?.bool ?? false
                        displayedValue =  knobStyle.titleOverride ?? knobStyle.adapter?.stringValue(for: value) ?? title
                    }
                }
            
        } // Root ZStack
        .modifier(KnobModifier(color: color, state: $knobState, animated: false))
        
        // Subscribes to isOn source publisher if needed
        
        .onAppear {
            /// If a binding is set, it overrides the parameter value publisher and the stateCondition closure is not applyed,
            /// Binding must wrap a boolean value
            if let isOnBinding = isOnBinding {
                knobState.isOn = isOnBinding.wrappedValue
            }
            else
            /// If a publisher is set, it overrides the parameter value publisher and the stateCondition closure is not applyed,
            /// Publisher is must send a boolean value
            if let isOnPublisher = isOnPublisher {
                onPublisherListener = isOnPublisher.sink(receiveValue: { value in
                    knobState.isOn = value
                    knobState.highlighted = knobState.isOn
                })
            } else {
            onPublisherListener = stateSource?.$doubleValue.sink(receiveValue: { value in
                knobState.isOn = stateOnCondition?(value) ?? false
                knobState.highlighted = knobState.isOn
            })
            }
        }
        .onDisappear {
            onPublisherListener?.cancel()
        }
    }
}

//MARK: - Previews -
//
//struct KnobButton_Previews: PreviewProvider {
//    static var previews: some View {
//        KnobButton(parameterIdentifier: PXIdentifier.testInt)
//        KnobButton(parameter: AnyParameter.testInt)
//    }
//}
