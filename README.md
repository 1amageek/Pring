<div style="text-align: center; width: 100%">
<img src="https://github.com/1amageek/Pring/blob/master/Pring.png", width="100%">

 [![Version](http://img.shields.io/cocoapods/v/Pring.svg)](http://cocoapods.org/?q=Pring)
 [![Platform](http://img.shields.io/cocoapods/p/Pring.svg)](http://cocoapods.org/?q=Pring)
 [![Downloads](https://img.shields.io/cocoapods/dt/Pring.svg?label=Total%20Downloads&colorB=28B9FE)](https://cocoapods.org/pods/Pring)

</div>

# Pring <β>
Firestore model framework.

<b> ⚠️ This code still contains bugs.</b>

Please report issues [here](https://github.com/1amageek/Pring/issues/new)

## Requirements ❗️
- iOS 10 or later
- Swift 4.0 or later
- [Firebase firestore](https://firebase.google.com/docs/database/ios/start)
- [Firebase storage](https://firebase.google.com/docs/storage/ios/start)
- [Cocoapods](https://github.com/CocoaPods/CocoaPods/milestone/32) 1.4 ❗️

## Installation ⚙
#### [CocoaPods](https://github.com/cocoapods/cocoapods)

- Insert `pod 'Pring' ` to your Podfile.
- Run `pod install`.


## Feature 🎊

☑️ You can define Firestore's Document scheme.<br>
☑️ Of course type safety.<br>
☑️ It seamlessly works with Firestore and Storage.<br>
☑️ You can easily associate subcollections.<br>
☑️ Support GeoPoint.<br>

## Usage

### Scheme 

The definition of the schema inherits from Object.

``` swift
@objcMembers
class MyObject: Object {
    dynamic var array: [String]                     = ["array"]
    dynamic var set: Set<String>                    = ["set"]
    dynamic var bool: Bool                          = true
    dynamic var binary: Data                        = "data".data(using: .utf8)!
    var file: File                          　　　　　　　　　　　　　　　　= File(data: UIImageJPEGRepresentation(UIImage(named: "")!, 1))
    dynamic var url: URL                            = URL(string: "https://firebase.google.com/")!
    dynamic var int: Int                            = Int.max
    dynamic var float: Double                       = Double.infinity
    dynamic var date: Date                          = Date(timeIntervalSince1970: 100)
    dynamic var geoPoint: GeoPoint                  = GeoPoint(latitude: 0, longitude: 0)
    dynamic var dictionary: [AnyHashable: Any]      = ["key": "value"]
    var relation: Relation<TestDocument>   　　　　　　　　　　　　　　　　 = []
    dynamic var string: String                      = "string"
}
```

| DataType | Description |
|---|---|
|Array|It is Array type.|
|Set|It is Set type.In Firestore it is expressed as `{"value": true}`.|
|Bool|It is a boolean value.|
|File|It is File type. You can save large data files.|
|URL|It is URL type. It is saved as string in Firestore.|
|Int|It is Int type.|
|Float|It is Float type. In iOS, it will be a 64 bit Double type.|
|Date|It is Date type.|
|GeoPoint|It is GeoPoint type.|
|Dictionary|It is a Dictionary type. Save the structural data.|
|Relation|It is Relation type. Relation type. Holds the count stored in SubCollection.|
|String|It is String type.|
|Null|It is Null type.|

### Save and Update

#### Save
``` swift
let object: MyObject = MyObject()
object.save()
```

#### Retrieve
``` swift
MyObject.get(document!.id, block: { (document, error) in
    // do something
})
```

#### Update
``` swift
MyObject.get(document!.id, block: { (document, error) in
    document.string = "newString"
    document.update { error in
       // update
    }
})
```

#### Delete
``` swift
MyObject.delete(id: document!.id)
```


### DataSource

DataSource is a class for easy handling of data retrieval from Collection.
``` swift
override func viewDidLoad() {
    super.viewDidLoad()

    self.dataSource = DataSource(reference: User.reference, block: { [weak self](changes) in
        guard let tableView: UITableView = self?.tableView else { return }

        switch changes {
        case .initial:
            tableView.reloadData()
        case .update(let deletions, let insertions, let modifications):
            tableView.beginUpdates()
            tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
            tableView.endUpdates()
        case .error(let error):
            print(error)
        }
    })
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.dataSource?.count ?? 0
}
```
