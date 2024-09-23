# PredicateHelper
A simple (rough!) macro to add a member helper matching a SwiftData `#Predicate` generating method.

When working with SwiftData, I find myself writing code in the following form to break down complex logic for filtering `@Model` items...

```swift
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
}
```

With this I can compose fairly readable predicates for SwiftUI `View`s with the following:

```swift
let isStartEnd = Item.hasDateVisibility(.startEnd)
let startEndShowsOnDay = Item.startEndAppliesDuring(dayRange)

let predicate = #Predicate<Item> { item in
    isStartEnd.evaluate(item) && startEndShowsOnDay.evaluate(item) }
```

Since I might elsewhere want to filter some collection with similar logic, this macro will generate a matching function on the `@Model` item:

```swift
func startEndAppliesDuring(_ range: ClosedRange<Date>) -> Bool
{
    let distantPast = Date.distantPast
    let distantFuture = Date.distantFuture

    let decider: (Self) -> Bool =  { item in
            ((item.startDate ?? item.endDate ?? distantFuture) < range.upperBound)
            &&
            ((item.endDate ?? item.startDate ?? distantPast) >= range.lowerBound)
        }

    return decider(self)
}
```

