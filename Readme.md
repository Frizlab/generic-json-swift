# Generic JSON

<picture><img alt="Compatible from Swift 5.1 to 6." src="https://img.shields.io/badge/Swift-6.0_%7C_5.10--5.1-blue"></picture>
<picture><img alt="Compatible with macOS, iOS, visionOS, tvOS and watchOS." src="https://img.shields.io/badge/Platforms-macOS_%7C_iOS_%7C_visionOS_%7C_tvOS_%7C_watchOS-blue"></picture>
<picture><img alt="Compatible with Linux, Windows, WASI and Android." src="https://img.shields.io/badge/Platforms-Linux_%7C_Windows_%7C_WASI_%7C_Android-blue"></picture>
[![](<https://img.shields.io/github/v/release/Frizlab/generic-json>)](<https://github.com/xcode-actions/Frizlab/generic-json>)

Generic JSON makes it easy to deal with freeform JSON strings without creating a separate, well-typed structure.

## Codable and Freeform JSON

Swift 4 introduced a new JSON encoding and decoding machinery represented by the `Codable` protocol.
The feature is very nice and very type-safe, meaning it’s no longer possible to just willy-nilly decode a JSON string pulling random untyped data from it.
Which is good™ most of the time–but what should you do when you _do_ want to just willy-nilly encode or decode a JSON string without introducing a separate, well-typed structure for it?

For example:

```swift
/* error:
 *  heterogeneous collection literal could only be inferred to '[String : Any]';
 *  add explicit type annotation if this is intentional. */
let json = [
   "foo": "foo",
   "bar": 1,
]

/* Okay then: */
let json: [String: Any] = [
   "foo": "foo",
   "bar": 1,
]

/* But: fatal error: Dictionary<String, Any> does not conform to Encodable because Any does not conform to Encodable. */
let encoded = try JSONEncoder().encode(json)
```

So this doesn’t work very well.
Also, the `json` value can’t be checked for equality with another, although arbitrary JSON values _should_ support equality.

Enter `JSON`.

## Usage

### Create a `JSON` structure

```swift
let json: JSON = [
   "foo": "foo",
   "bar": 1,
]

/* #"{"bar":1,"foo":"foo"}"# */
let str = try String(data: try JSONEncoder().encode(json), encoding: .utf8)!
let hopefullyTrue = (json == json) /* true! */
```

### Convert `Encodable` objects into a generic JSON structure

```swift
struct Player: Codable {
   let name: String
   let swings: Bool
}

let val = try JSON(encodable: Player(name: "Miles", swings: true))
val == [
   "name": "Miles",
   "swings": true,
] /* true */
```

### Query Values

Consider the following `JSON` structure:

```swift
let json: JSON = [
   "num": 1,
   "str": "baz",
   "bool": true,
   "obj": [
      "foo": "jar",
      "bar": 1,
   ]
]
```

Querying values can be done using optional property accessors, subscripting or dynamic member subscripting:

```swift
/* Property accessors. */
if let str = json.objectValue?["str"]?.stringValue { … }
if let foo = json.objectValue?["obj"]?.objectValue?["foo"]?.stringValue { … }

/* Subscripting. */
if let str = json["str"]?.stringValue { … }
if let foo = json["obj"]?["foo"]?.stringValue { … }

/* Dynamic member subscripting. */
if let str = json.str?.stringValue { … }
if let foo = json.obj?.foo?.stringValue { … }
```

You may even drill through nested structures using a dot-separated key path:

```swift
let val = json[keyPath: "obj.foo"] /* "jar" */
```
