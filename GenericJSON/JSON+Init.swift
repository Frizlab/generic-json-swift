import Foundation



public extension JSON {
	
	/** 
	 Create a JSON value from anything.
	 
	 Argument has to be a valid JSON structure:
	  a `Double`, `Int`, `String`, `Bool`, an `Array` of those types or a `Dictionary` of those types.
	 
	 You can also pass `nil` or `NSNull`, both will be treated as `.null`. */
	init(_ value: Any) throws {
		switch value {
			case _ as NSNull:                               self = .null
			case let opt as Optional<Any> where opt == nil: self = .null
			case let num as NSNumber where num.isBool:      self = .bool  (num.boolValue)
			case let num as NSNumber:                       self = .number(num.doubleValue)
			case let str as String:                         self = .string(str)
			case let bool as Bool:                          self = .bool(bool)
			case let array as [Any]:                        self = .array(try array.map(JSON.init))
			case let dict as [String: Any]:                 self = .object(try dict.mapValues(JSON.init))
			default:
				throw Err.valueIsNotJSONCompatible
		}
	}
	
	/**
	 Create a JSON value from an `Encodable`.
	 
	 This will give you access to the “raw” encoded JSON value the `Encodable` is serialized into. */
	init<T: Encodable>(encodable: T) throws {
		let encoded = try JSONEncoder().encode(encodable)
		self = try JSONDecoder().decode(JSON.self, from: encoded)
	}
	
}

extension JSON : ExpressibleByBooleanLiteral {
	
	public init(booleanLiteral value: Bool) {
		self = .bool(value)
	}
	
}

extension JSON : ExpressibleByNilLiteral {
	
	public init(nilLiteral: ()) {
		self = .null
	}
	
}

extension JSON : ExpressibleByArrayLiteral {
	
	public init(arrayLiteral elements: JSON...) {
		self = .array(elements)
	}
	
}

extension JSON : ExpressibleByDictionaryLiteral {
	
	public init(dictionaryLiteral elements: (String, JSON)...) {
		var object: [String:JSON] = [:]
		for (k, v) in elements {
			object[k] = v
		}
		self = .object(object)
	}
	
}

extension JSON : ExpressibleByFloatLiteral {
	
	public init(floatLiteral value: Double) {
		self = .number(value)
	}
	
}

extension JSON : ExpressibleByIntegerLiteral {
	
	public init(integerLiteral value: Int) {
		self = .number(Double(value))
	}
}

extension JSON : ExpressibleByStringLiteral {
	
	public init(stringLiteral value: String) {
		self = .string(value)
	}
	
}


/* ****************
   MARK: - NSNumber
   **************** */

fileprivate extension NSNumber {
	
	/**
	 Boolean value indicating whether this `NSNumber` wraps a boolean.
	 
	 For example, when using `NSJSONSerialization` `Bool` values are converted into `NSNumber` instances.
	 
	 - SeeAlso: <https://stackoverflow.com/a/49641315> */
	var isBool: Bool {
		let objCType = String(cString: self.objCType)
		return (
			(compare(Self .trueNumber) == .orderedSame && objCType == Self .trueObjCType) ||
			(compare(Self.falseNumber) == .orderedSame && objCType == Self.falseObjCType)
		)
	}
	
	private static let  trueNumber = NSNumber(value: true)
	private static let falseNumber = NSNumber(value: false)
	private static let  trueObjCType = String(cString:  trueNumber.objCType)
	private static let falseObjCType = String(cString: falseNumber.objCType)
	
}
