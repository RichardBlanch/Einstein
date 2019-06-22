# Collection

[Source](../../Sources/Einstein/Shared/Extensions/Collection+Extension.swift)

### subscript(safe index: Index) -> Element?

This subscript method lets you safely get an item from an array from an index of the array. If the index is out of bounds for the array this method will return nil. This is really useful if you want to get an element from an array in Swift safely without causing your application to crash if the index is out of bounds.

#### Example

```swift
let arr: [Int] = [1, 2, 3, 4, 5]

let x: Int? = arr[safe: 0] // 1
let y: Int? = arr[safe: 5] // nil
```
