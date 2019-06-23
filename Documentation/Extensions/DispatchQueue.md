# DispatchQueue

[Source](../../Sources/Einstein/Shared/Extensions/DispatchQueue+Extension.swift)

### convenience init(from key: StringKey)

This init method creates a new DispatchQueue based on the StringKey provided.

#### Example

```swift
let newQueue: DispatchQueue = DispatchQueue(from: AppManager.BackgroundQueueLabel)

private extension AppManager {
    static let BackgroundQueueLabel = StringKey(rawValue: "com.Einstein.BackgroundQueue")
}
```
