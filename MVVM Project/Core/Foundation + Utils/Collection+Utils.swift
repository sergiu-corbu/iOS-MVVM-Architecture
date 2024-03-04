//
//  Collection+Utils.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 17.11.2022.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Collection {
    
    typealias IteratorIndex = Indices.Iterator.Element
    
    var indexEnumeratedArray: Array<(offset: IteratorIndex, element: Iterator.Element)> {
        return Array(zip(indices, self))
    }
}

extension Array where Element: Equatable {

    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {
            return
        }
        remove(at: index)
    }
    
    mutating func move(_ element: Element, to newIndex: Index) {
        guard let oldIndex: Int = firstIndex(of: element) else {
            return
        }
        move(from: oldIndex, to: newIndex)
    }
    
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        if oldIndex == newIndex { return }
        
        if abs(newIndex - oldIndex) == 1 {
            return swapAt(oldIndex, newIndex)
        }
        
        insert(remove(at: oldIndex), at: newIndex)
    }
}

extension Sequence where Iterator.Element: Hashable {
    
    func uniqueValues() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter({ seen.insert($0).inserted })
    }
}


extension Set {
    
    mutating func updateOrRemove(_ element: Element) {
        if contains(element) {
            self.remove(element)
        } else {
            self.insert(element)
        }
    }
}

extension Dictionary {
    
    mutating func merge(other: Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
