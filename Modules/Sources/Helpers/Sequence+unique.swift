import Foundation

//https://www.avanderlee.com/swift/unique-values-removing-duplicates-array/

extension Sequence where Iterator.Element: Hashable {
    /// Allow to filter duplicated items on a `Sequence` without resorting to `Set` thus preserving order
    /// - Returns: Sequence ordered of unique elements
    public func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
