//
//  Event.swift
//  BoutTime
//
//  Created by Katherine Ebel on 10/25/16.
//  Copyright © 2016 Katherine Ebel. All rights reserved.
//

import Foundation

protocol EventType {
  var name: String { get }
  var date: NSDate { get }
}
enum ResourceError: Error {
  case InvalidResource
  case ConversionError
}

struct Event: EventType {
  let name: String
  let date: NSDate
}

class PlistConverter {
  class func dictionaryFromFile(resource: String, ofType type: String) throws -> [String: AnyObject] {
    guard let path = Bundle.main.path(forResource: resource, ofType: type) else {
      throw ResourceError.InvalidResource
    }
    
    guard let dictionary = NSDictionary.init(contentsOfFile: path),
    let castDictionary = dictionary as? [String: AnyObject] else {
      throw ResourceError.ConversionError
    }
    return castDictionary
  }
}

class EventUnarchiver {
  class func vendingInventoryFromDictionary(dictionary: [String: AnyObject]) throws -> [EventType] {
    var events: [EventType]
    for (key, value) in dictionary {
      if let eventDict = value as? [String: Double],
        let price = itemDict["price"], let quantity = itemDict["quantity"] {
        let item = VendingItem(price: price, quantity: quantity)
        guard let vendingKey = VendingSelection.init(rawValue: key) else {
          throw InventoryError.InvalidKey
        }
        inventory.updateValue(item, forKey: vendingKey)
      }
    }
    return inventory
  }
}
