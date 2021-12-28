//
//  KnobSlider.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 05/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//


import SwiftUI
import Paralex
import Combine

public struct KnobSlider: View, ParameterKnobProtocol {
    
    // MARK: - Properties
    
    // ParameterHandleBox Protocol
    @StateObject public var parameterNode: ParameterGraphNode
    
    // Knob Protocol
    @State public var knobState = KnobState()
    
    public var knobStyle = KnobStyle()
    
    // Private Properties
    @State private var displayedValue: String = "-"
    
    //MARK: - Initialization
    
    public init(parameterNode: ParameterGraphNode, knobStyle: KnobStyle = KnobStyle()) {
        _parameterNode = StateObject(wrappedValue: parameterNode)
        self.knobStyle = knobStyle
    }
    
    //MARK: - Body
    
    public var body: some View {
        
        ZStack {
            if let parameter = parameterNode.parameter {
                KnobCell(text: displayedValue, subText: subTitle, showSubtext: knobStyle.showSubtitle)
                    .onReceive(parameter.$doubleValue) { value in
                        if let adapter = knobStyle.adapter {
                            self.displayedValue = adapter.stringValue(adaptedValue: value)
                        } else {
                            self.displayedValue = parameter.formattedValue
                        }
                    }
                
                // If Knob is enabled, we add the tap gesture
                
                if knobState.enabled {
                    let slide = KnobSlideModifier(pixelToValueRatio: 1 /* TO FIX */,
                        action: { event in
                            
                            knobState.pressed = event.phase != .ended
                            parameter.offsetValue(by: event.value)
                        print(parameter.doubleValue)
                            
                        })
                    Rectangle().foregroundColor(.white.opacity(0.001))
                    .modifier(slide)
                }
            } else {
                KnobCell(text: displayedValue, subText: subTitle, showSubtext: knobStyle.showSubtitle)
            }
        } // Root ZStack
        .modifier(KnobModifier(color: color, state: $knobState, animated: true))
    }
}

//MARK: - Previews -

struct KnobSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
//        KnobSlider(parameterNode: ParameterGraphNode(with: <#T##AnyParameter#>, in: <#T##GroupGraphNode#>))
//        KnobSlider(parameter: AnyParameter.testInt)
        }
    }
}
