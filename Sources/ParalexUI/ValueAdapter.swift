//
//  ValueAdapter.swift
//  Pulsar Lab
//
//  Created by Tristan Leblanc on 23/02/2020.
//  Copyright © 2020 Moose Factory Software. All rights reserved.
//

import Foundation
import Paralex

/// ValueAdapter adapts the value from a 0..1 range to another range
///
/// It also controls the number of decimals and the minimal value delta ( granularity )

open class ValueAdapter: CustomStringConvertible, CustomDebugStringConvertible {

    open var get: (Double, ValueAdapter) -> Double
    open var convertToInternal: (Double, ValueAdapter) -> Double

    open var min: Double = 0
    open var max: Double = 1
    open var range: Double { return max - min }

    open var formatter: Formatter?

    open var positive: Bool = false

    open var notSetIfZero: Bool = false

    open var decimals: Int = 0 {
        didSet {
            (formatter as? NumberFormatter)?.maximumFractionDigits = decimals
            (formatter as? NumberFormatter)?.minimumFractionDigits = hideZeroDecimal ? 0 : decimals
        }
    }

    open var hideZeroDecimal: Bool = true {
        didSet {
            (formatter as? NumberFormatter)?.minimumFractionDigits = hideZeroDecimal ? 0 : decimals
        }
    }
    open var granularity: Double = 1

    open var description: String {
        return "[\(min)..\(max)]"
    }

    public var debugDescription: String {
        let format = formatter != nil ? "formatter: \(formatter!)" : ""
        return "\(String(describing: self)) [\(min)..\(max)] positive: \(positive) \(format)"
    }

    static func makeFormatter(decimals: Int = 0) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = 0
        formatter.decimalSeparator = "."
        return formatter
    }

    // MARK: - Formatters

    static let percentFormatter = PercentFormatter()
    static let midiFormatter = IntFormatter()
    static let offsetFormatter = OffsetFormatter()
    static let intFormatter = IntFormatter()

    static let optionalIntFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.zeroSymbol = "-"
        return formatter
    }()

    static let realFormatter = RealFormatter()
    static let factorFormatter = FactorFormatter()
    
    public static func enumerationFormatter(items: [PXItem]) -> Formatter {
        let formatter = EnumerationFormatter(items: items)
        return formatter
    }

    public func value(for value: Double?) -> Double? {
        guard let value = value else { return nil }
        return get(value, self)
    }

    public func stringValue(for value: Double?) -> String {
        guard let value = self.value(for: value) else {
            return "<nil>"
        }
        return formatter?.string(for: value) ?? "\(get(value, self))"
    }

    public func stringValue(adaptedValue: Double?) -> String {
        guard let value = adaptedValue else {
            return ""
        }
        return formatter?.string(for: adaptedValue) ?? "\(value))"
    }

    public func setValue(_ value: Double) -> Double {
        return convertToInternal(value, self)
    }

    public init(formatter: Formatter, positive: Bool = true, min: Double, max: Double,
         decimals: Int = 0, granularity: Double = 1, notSetIfZero: Bool = false,
         get: @escaping (Double, ValueAdapter) -> Double, set: @escaping (Double, ValueAdapter) -> Double ) {
        self.min = min
        self.max = max
        self.positive = positive
        self.formatter = formatter
        self.get = get
        self.convertToInternal = set
        self.decimals = decimals
        self.granularity = granularity
        self.notSetIfZero = notSetIfZero
    }

    // MARK: - Adapters

    public static func makePercentAdapter(positive: Bool = false) -> ValueAdapter {
        let percent = ValueAdapter(
            formatter: ValueAdapter.percentFormatter,
            positive: positive,
            min: positive ? 0 : -1,
            max: 1,
            get: { value, adapter in
                if positive {
                    return value * adapter.range + adapter.min
                }
                return  (value + 1) * 0.5 * adapter.range + adapter.min
        },
            set: { value, adapter in
                if positive {
                    return (value - adapter.min) / adapter.range
                }
                return ((value - adapter.min) / (adapter.range * 0.5)) - 1
        })
        return percent
    }

    public static func makeMidiAdapter(min: Int = 0, max: Int = 127, signed: Bool = false) -> ValueAdapter {
        let midi = ValueAdapter(
            formatter: ValueAdapter.midiFormatter,
            positive: true,
            min: Double(min),
            max: Double(max),
            get: { value, adapter in
                return round(value * adapter.range)
        },
            set: { value, adapter -> Double in
                return value / adapter.range
        })
        return midi
    }

    public static func makeTransposeAdapter(inSemitones: Bool = true) -> ValueAdapter {
        let range: Double = inSemitones ? 96 : 8

        let midi = ValueAdapter(
            formatter: ValueAdapter.offsetFormatter,
            positive: false,
            min: -1,
            max: 1,
            get: { value, adapter in
                return round( value * range )
        },
            set: { value, adapter in
                return value /  range
        })
        return midi
    }

    public static func makeAdapter() -> ValueAdapter {
        let adapter = ValueAdapter(
            formatter: ValueAdapter.midiFormatter,
            positive: true,
            min: 0,
            max: 1,
            get: { value, adapter in
                return value
        },
            set: { value, adapter -> Double in
                return value
        })
        return adapter
    }

    public static func makeBoolAdapter() -> ValueAdapter {
        let adapter = ValueAdapter( formatter: Formatter.onOffSymbolFormatter,
                                    positive: true,
                                    min: 0,
                                    max: 1,
                                    get: { value, adapter in
                                        return value
                                },
                                    set: { value, adapter -> Double in
                                        return value
                        
        })
        return adapter
    }

    public static func makeIntAdapter(min: Int, max: Int, positive: Bool, optional: Bool = false) -> ValueAdapter {
        let adapter = ValueAdapter( formatter: optional ? ValueAdapter.optionalIntFormatter : ValueAdapter.intFormatter,
                                    positive: positive,
                                    min: Double(min),
                                    max: Double(max),
                                    get: { value, adapter in
                                        return round( adapter.min + value * adapter.range )
        },
                                    set: { value, adapter in
                                        return (value - adapter.min) / adapter.range
        })
        return adapter
    }

    public static func makeRealAdapter(min: Double, max: Double, positive: Bool) -> ValueAdapter {
        let formatter = ValueAdapter.realFormatter
        let adapter = ValueAdapter( formatter: formatter,
                                    positive: positive,
                                    min: min,
                                    max: max,
                                    get: { value, adapter in
                                        return adapter.min + value * adapter.range
        },
                                    set: { value, adapter in
                                        return (value - adapter.min) / adapter.range
        })
        return adapter
    }

    public static func makeFactorAdapter(min: Double, max: Double, positive: Bool) -> ValueAdapter {
        let formatter = ValueAdapter.factorFormatter
        let adapter = ValueAdapter( formatter: formatter,
                                    positive: positive,
                                    min: min,
                                    max: max,
                                    get: { value, adapter in
                                        return adapter.min + value * adapter.range
        },
                                    set: { value, adapter in
                                        return (value - adapter.min) / adapter.range
        })
        return adapter
    }

    public static func makeEnumerationAdapter(items: [PXItem]) -> ValueAdapter {
        let formatter = ValueAdapter.enumerationFormatter(items: items)
        let range = Double(items.count)
        let adapter = ValueAdapter( formatter: formatter,
                                    positive: true,
                                    min: 0,
                                    max: range,
                                    get: { value, adapter in
                                        return round( value * range )
        },
                                    set: { value, adapter in
                                        return value /  range
        })
        return adapter
    }

}
