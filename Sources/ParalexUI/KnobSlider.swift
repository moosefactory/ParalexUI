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
    @State public var parameter: PXParameter?
    
    public var _parameterIdentifier: PXIdentifier?

    
    // Knob Protocol
    @State public var knobState = KnobState()
    
    public var knobStyle = KnobStyle()
    
    // Private Properties
    @State private var displayedValue: String = "-"
    
    //MARK: - Initialization
    
    public init(parameter: PXParameter, knobStyle: KnobStyle = KnobStyle(showIcon: false)) {
        _parameter = State(wrappedValue: parameter)
        self.knobStyle = knobStyle
    }
    
    public init(identifier: PXIdentifier, knobStyle: KnobStyle = KnobStyle(showIcon: false)) {
        _parameterIdentifier = identifier
        self.knobStyle = knobStyle
    }
    
    //MARK: - Body
    
    public var body: some View {
        
        ZStack {
            if let parameter = parameter {
                KnobCell(style: knobStyle, text: displayedValue, subText: subTitle, showSubtext: knobStyle.showSubtitle, symbolName: parameter.symbolName)
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
                        print("\(parameter.path) = \(parameter.doubleValue)")
                            
                        })
                    Rectangle().foregroundColor(.white.opacity(0.001))
                    .modifier(slide)
                }
            } else {
                KnobCell(style: knobStyle,
                         text: displayedValue,
                         subText: subTitle,
                         showSubtext: knobStyle.showSubtitle,
                         symbolName: parameter?.symbolName)
            }
        } // Root ZStack
        .modifier(KnobModifier(color: color, state: $knobState, animated: true))
    }
}

//MARK: - Previews -

struct KnobSlider_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
//        KnobSlider(parameter: PXParameter(with: <#T##AnyParameter#>, in: <#T##PXGroup#>))
//        KnobSlider(parameter: AnyParameter.testInt)
        }
    }
}
