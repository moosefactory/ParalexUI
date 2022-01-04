//
//  KnobTapModifier.swift
//  Seq-One
//
//  Created by Tristan Leblanc on 04/12/2021.
//  Copyright © 2021 Moose Factory Software. All rights reserved.
//

import SwiftUI

protocol KnobModifierBase {
    var action: ((KnobEvent)->Void)? { get set }
}

struct KnobTapModifier: ViewModifier, KnobModifierBase {
    @Binding var mouseDragIn: Bool
    @Binding var mouseDragWithCommandIn: Bool

    var action: ((KnobEvent)->Void)?

    func body(content: Content) -> some View {
        GeometryReader { geo in
        ZStack {
            content
                .gesture(
                    DragGesture(minimumDistance: 0)
                    #if os(macOS)
                        .modifiers(.command)
                    #endif
//                        .onChanged { value in
//                            mouseDragWithCommandIn = geo.frame(in: CoordinateSpace.local).contains(value.location)
//                        }
                        .onEnded { value in
                            if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                action?(KnobEvent(type: .tap, modifiers: [.command]))
                            }
//                            mouseDragWithCommandIn = false
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                    #if os(macOS)
                        .modifiers(.control)
                    #endif
                        .onEnded { value in
                            if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                action?(KnobEvent(type: .tap, modifiers: [.control]))
                            }
                        }
                )
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            mouseDragIn = geo.frame(in: CoordinateSpace.local).contains(value.location)
                        }
                        .onEnded { value in
                            if geo.frame(in: CoordinateSpace.local).contains(value.location) {
                                action?(KnobEvent(type: .drag, modifiers: []))
                            }
                            mouseDragIn = false
                        }
                )
            }
        }
    }
}

struct KnobTapModifier_Previews: PreviewProvider {
    static var previews: some View {
        Text("Test").modifier(KnobTapModifier(mouseDragIn: .constant(false), mouseDragWithCommandIn: .constant(false)) { command in
            print("action")
        })
    }
}
