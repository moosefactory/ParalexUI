//
//  ButtonUIModifier.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 28/11/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI


public struct ButtonUIModifier: ViewModifier, MachineUIModifier {
    
    public var color: Color = .blue
    
    /// isPressed
    ///
    /// isPressed is true when the view has a touch down
    @State public var isPressed: Bool = false
    
    /// highlighted
    ///
    /// A button is said to be highlighted when it
    /// indicates a 'on' state.
    public var isHighlighted: Bool = false
    
    @State public var isDisabled: Bool = false
    
    @State private var dragValue: CGFloat?
    
    public var pixelToValueRatio: Double = 1
    
    public var sensitivity: Double = 0.25
    
    public var isBorderVisible: Bool = false

    // MARK: Actions
    
    public var commandAction: (()->Void)?
    public var dragAction: ((Double)->Void)?
    public var action: (()->Void)?

    // MARK: Getters
    
    var highlightedColor: Color { color.opacity(0.7) }
    var pressedColor: Color { color.opacity(0.8) }
    var fillColor: Color { color.opacity(0.2) }
    
        public init(color: Color = .blue,
                    isHighlighted: Bool = false,
                    isBorderVisible: Bool = false,
                    commandAction: (()->Void)? = nil,
                    dragAction: ((Double)->Void)? = nil,
                    action: (()->Void)? = nil) {
            self.color = color
            self.isBorderVisible = isBorderVisible
            self.isHighlighted = isHighlighted
            self.commandAction = commandAction
            self.dragAction = dragAction
            self.action = action
        }
    
    var computedColor: Color {
        if isPressed { return pressedColor }
        if isHighlighted { return highlightedColor }
        return fillColor
    }
    
    public func body(content: Content) -> some View {
        
        GeometryReader { geo in
            
            ZStack {
                RoundedRectangle(cornerRadius: 5, style: SwiftUI.RoundedCornerStyle.circular)
                    .foregroundColor(computedColor)
                content
                if isBorderVisible {
                    RoundedRectangle(cornerRadius: 5, style: SwiftUI.RoundedCornerStyle.circular)
                        .stroke(color, lineWidth: 2)
                        .foregroundColor(.clear)
                }

                Rectangle()
                    //.background(.clear)
                    .foregroundColor(.white)
                    .opacity(0.001)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                        #if os(macOS)
                            .modifiers(EventModifiers.command).onEnded({ value in
                                commandAction?()
                            })
                        #endif
                            .onChanged({ value in })
                    )
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
                                
                                self.isPressed =
                                dragAction == nil ? geo.frame(in: CoordinateSpace.local).contains(value.location)
                                : dragValue != nil

                      
                                let valueOffset = -pixelsOffset * pixelToValueRatio * sensitivity
                                
//                                print("TY: \(ty) - ∂ : \(pixelsOffset)px -> \(valueOffset)")
                                
                                if let dragAction = dragAction, valueOffset != 0 {
                                    dragAction(valueOffset)
                                }
                            }
                            .onEnded { value in
                                if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                    action?()
                                }

                                dragValue = nil
                                self.isPressed = false
                            }
                    )
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                self.isPressed = false
                                if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                    action?()
                                }
                            }
                        #if os(macOS)
                            .modifiers(EventModifiers.command).onEnded({ value in
                                commandAction?()
                            })
                        #endif
                            .onChanged({ value in
                                if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                    self.isPressed = true
                                    action?()
                                } else {
                                    self.isPressed = false
                                }
                            })
                        
                    )
            }
        }
    }
    
}

struct ButtonUIModifier_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Text("Normal").modifier(ButtonUIModifier())
            Text("Pressed").modifier(ButtonUIModifier())
            Text("Highlighted").modifier(ButtonUIModifier())
        }
    }
}
