//
//  Array+Extension.swift
//  ios-postman
//
//  Created by Hanyuan Ye on 2020-03-07.
//  Copyright © 2020 hanyuanye. All rights reserved.
//

import Foundation

extension Array {
    func get(_ index: Int) -> Element? {
        guard index >= 0, index <= endIndex else {
            return nil
        }
        
        return self[index]
    }
    
    func appending(_ element: Element) -> Array<Element> {
        var newArray = self
        newArray.append(element)
        return newArray
    }
    
    func removing(_ index: Int) -> Array<Element> {
        guard index >= 0, index <= endIndex else { return self }
        
        var newArray = self
        newArray.remove(at: index)
        
        return newArray
    }
    
    func moving(from source: Int, to destination: Int) -> Array<Element> {
        guard source >= 0, source <= endIndex, destination >= 0, destination <= endIndex else {
            return self
        }
        
        var newArray = self
        newArray.insert(newArray.remove(at: source), at: destination)
        
        return newArray
    }
    
    func replacing(_ element: Element, at index: Index) -> Array<Element> {
        guard index >= 0, index <= endIndex else { return self }
        
        var newArray = self
        newArray[index] = element
        
        return newArray
    }
}
