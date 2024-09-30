import PredicateHelper

import Foundation

struct Item
{
    let startDate: Date?
    let endDate: Date?
    
    @PredicateHelper static func startEndAppliesDuring(_ range: ClosedRange<Date>)
    -> Predicate<Item> {
        let distantPast = Date.distantPast
        let distantFuture = Date.distantFuture

        return #Predicate<Item> { item in
            ((item.startDate ?? item.endDate ?? distantFuture) < range.upperBound)
            &&
            ((item.endDate ?? item.startDate ?? distantPast) >= range.lowerBound)
        }
    }
    
    @PredicateHelper static func isOver(beforeDate: Date = Date.now)
    -> Predicate<Item> {
        let distantPast = Date.distantPast
        
        return #Predicate<Item> { item in
            ((item.startDate ?? distantPast) < beforeDate)
            &&
            ((item.endDate ?? distantPast) >= beforeDate)
        }
    }
}

