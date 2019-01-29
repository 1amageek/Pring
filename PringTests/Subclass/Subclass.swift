//
//  InheritableDocument.swift
//  PringTests
//
//  Created by Shunpei Kobayashi on 2019/01/13.
//  Copyright © 2019 Stamp Inc. All rights reserved.
//

import Foundation
import Pring

@objcMembers
class SubclassCustomDocument: CustomDocument{
    dynamic var childInt: Int = 0
}

@objcMembers
class SubclassNestedItem: NestedItem{
    dynamic var childInt: Int = 0
}

@objcMembers
class SubclassMultipleFilesDocument: MultipleFilesDocument{
    let subFiles: NestedCollection<SubclassMultipleFilesNestedItem> = []
    
    let subShallowFiles: NestedCollection<SubclassMultipleFilesShallowPathItem> = []
    
    let subReferenceShallowFile: Reference<SubclassMultipleFilesShallowPathItem> = .init()
    
    let subRelationShallowFile: Relation<SubclassMultipleFilesShallowPathItem> = .init()
}

@objcMembers
class SubclassTestDocument: TestDocument {
    dynamic var testInt: Int = 0
}

@objcMembers
class SubclassCollectionObject: CollectionObject{
   let subReferenceCollection: ReferenceCollection<SubclassCollectionObject> = []

}

@objcMembers
class SubclassReferenceItem: ReferenceItem{
    
}

@objcMembers
class SubclassDataSourceItem: DataSourceItem{
    
}

@objcMembers
class SubclassMultipleFilesShallowPathItem: MultipleFilesShallowPathItem{
    
}

@objcMembers
class SubclassMultipleFilesNestedItem:  MultipleFilesNestedItem{
    
}
