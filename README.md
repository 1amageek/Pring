<div style="text-align: center; width: 100%">
<img src="https://github.com/1amageek/Pring/blob/master/Pring.png", width="100%">

 [![Version](http://img.shields.io/cocoapods/v/Pring.svg)](http://cocoapods.org/?q=Pring)
 [![Platform](http://img.shields.io/cocoapods/p/Pring.svg)](http://cocoapods.org/?q=Pring)
 [![Downloads](https://img.shields.io/cocoapods/dt/Pring.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Pring)

</div>

# Pring
Firestore model framework.

<b> ⚠️ This code still contains bugs.</b>

## Requirements ❗️
- iOS 10 or later
- Swift 4.0 or later
- [Firebase firestore](https://firebase.google.com/docs/database/ios/start)
- [Firebase storage](https://firebase.google.com/docs/storage/ios/start)

## Feature 🎊

☑️ You can define Firestore's Document scheme.
☑️ Of course type safety.
☑️ It seamlessly works with Firestore and Storage.
☑️ You can easily associate subcollections.
☑️ Support GeoPoint.

## Usage

### Scheme 

The definition of the schema inherits from Object.

``` swift
@objcMembers
class MyObject: Object {
    var array: [String]                     = ["array"]
    var set: Set<String>                    = ["set"]
    var bool: Bool                          = true
    var binary: Data                        = "data".data(using: .utf8)!
    var file: File                          = File(data: UIImageJPEGRepresentation(UIImage(named: "")!, 1))
    var url: URL                            = URL(string: "https://firebase.google.com/")!
    var int: Int                            = Int.max
    var float: Double                       = Double.infinity
    var date: Date                          = Date(timeIntervalSince1970: 100)
    var geoPoint: GeoPoint                  = GeoPoint(latitude: 0, longitude: 0)
    var dictionary: [AnyHashable: Any]      = ["key": "value"]
    var relation: Relation<TestDocument>    = []
    var string: String                      = "string"
}
```

| DataType | Description |
|---|---|
|Array|It is Array type.|
|Set|It is Set type.In Firestore it is expressed as `{"value": true}`.|
|bool|It is a boolean value.|
|file|It is File type. You can save large data files.|
|url|It is URL type. It is saved as string in Firestore.|
|int|It is Int type.|
|float|It is Float type. In iOS, it will be a 64 bit Double type.|
|date|It is Date type.|
|geoPoint|It is GeoPoint type.|
|dictionary|It is a Dictionary type. Save the structural data.|
|relation|It is Relation type. Relation type. Holds the count stored in SubCollection.|
|string|It is String type.|
|null|It is Null type.|

### Save and Update

#### Save

``` swift
let object: MyObject = MyObject()
object.save()
```

#### Retrieve

``` swift
TestDocument.get(document!.id, block: { (document, error) in
    // do something
})
```

#### Update

``` swift
TestDocument.get(document!.id, block: { (document, error) in
    document.string = "newString" // Please do not call save function. It will be saved automatically.
})
```

#### Delete
``` swift
TestDocument.delete(id: document!.id)
```
