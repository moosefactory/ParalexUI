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
    
    // MARK: - Properties
    
    // MachineViewProtocol
    //    @EnvironmentObject var machineController: MachineController
    
    // MARK: - State Properties
    
    // ParameterHandleBox Protocol
    @StateObject public var parameter: PXParameter
    
    // Knob Protocol
    @State public var knobState = KnobState()
    
    // Display Name
    @State public var displayedValue: String = "-"
    
    // Private Properties
    @State private var onPublisherListener: AnyCancellable?
    
    // If button edits a model, the binding is made here
    // Button can also be only an indicator by listening to the 'isOn' publisher
    var isOnBinding: Binding<Bool>?
    
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
                stateSource: PXParameter? = nil,
                stateOnCondition: ((Double)->Bool)? = { $0 > 0 },
                knobStyle: KnobStyle = KnobStyle(),
                action: ((KnobEvent)->Void)? = nil) {
        _parameter = StateObject(wrappedValue: parameter)
        _knobStyle = State(initialValue: knobStyle)
        self.stateSource = stateSource
        self.stateOnCondition = stateOnCondition
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        
        ZStack {
            if let parameter = parameter {
                KnobCell(text: displayedValue, subText: subTitle, showSubtext: knobStyle.showSubtitle)
                    .onReceive(parameter.$doubleValue) { value in
                        print("[KnobButton] AnyParameter \(parameter.identifier) Change")
                    }
                    .onAppear() {
                        displayedValue = title
                    }
            } else {
                KnobCell(text: displayedValue, subText: subTitle, showSubtext: knobStyle.showSubtitle)
            }
            
            // If Knob is enabled, we add the tap gesture
            
            if knobState.enabled {
                let tap = KnobTapModifier(mouseDragIn: $knobState.highlighted,
                                          mouseDragWithCommandIn: $knobState.selected) { event in
                    
                    if !event.commandDown {
                        if let bool = parameter as? BoolParameter {
                            bool.toggle()
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
                    
                    action?(KnobEvent(type: .tap, modifiers: [], phase: .ended, value: parameter.doubleValue))
                }
                Rectangle().foregroundColor(.white.opacity(0.001))
                    .modifier(tap)
            }
            
            // If we have a toggle and isOn source is not an external parameter,
            // we subscribe to the parameter to update isOn state when parameter value is changed
            
            if isToggle, stateSource == nil , let parameter = parameter {
                Rectangle().foregroundColor(.clear)
                    .onReceive(parameter.$doubleValue) { value in
                        knobState.isOn = stateOnCondition?(value) ?? false
                        displayedValue =  knobStyle.titleOverride ?? knobStyle.adapter?.stringValue(for: value) ?? title
                    }
            }
        } // Root ZStack
        .modifier(KnobModifier(color: color, state: $knobState, animated: false))
        
        // Subscribes to isOn source publisher if needed
        
        .onAppear {
            if let isOnBinding = isOnBinding {
                knobState.isOn = isOnBinding.wrappedValue
            }
            onPublisherListener = stateSource?.$doubleValue.sink(receiveValue: { value in
                knobState.isOn = stateOnCondition?(value) ?? false
                knobState.highlighted = knobState.isOn
            })
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
