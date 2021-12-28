//
//  KnobSlideModifier.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 05/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI

struct KnobSlideModifier: ViewModifier, KnobModifierBase {

    // Properties
    
    var pixelToValueRatio: Double = 1
    var sensitivity: Double = 0.25
    @State private var dragValue: CGFloat? = nil

    var action: ((KnobEvent)->Void)?
    
    func body(content: Content) -> some View {
        GeometryReader { geo in
        ZStack {
            content
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in

                            let ty = value.translation.height
                            
                            
                            if ty == 0 && dragValue == nil {
                                return
                            }
                            
                            var pixelsOffset: Double = 0
                            if let dv = dragValue {
                                pixelsOffset = ty - dv
                                dragValue = ty
                            }
                            else {
                                pixelsOffset = 0
                                dragValue = ty
                            }
                         
                  
                            let valueOffset = -pixelsOffset * pixelToValueRatio * sensitivity
                            if let action = action, valueOffset != 0 {
                                action(KnobEvent(type: .drag, phase: .changed, value: valueOffset))
                            }
                        }
                        .onEnded { value in
                            dragValue = nil
                            action?(KnobEvent(type: .drag, phase: .ended))
                        }
                )
            }
        }
    }
}

struct KnobSlideModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Test").modifier(KnobSlideModifier() { command in
            print("action")
        })
    }
}
