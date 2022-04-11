//
//  File.swift
//
//
//  Created by Jakob Mygind on 13/12/2021.
//

import Foundation
import XCTestDynamicOverlay

public struct FileClient<Value> {

    public var load: () -> Value?
    public var save: (Value?) -> Void

    public init(load: @escaping () -> Value?, save: @escaping (Value?) -> Void) {
        self.load = load
        self.save = save
    }
}

extension FileClient where Value: Codable {
    public static func live(key: String) -> Self {
        Self(
            load: { loadValue(forKey: key) },
            save: { saveValue($0, forKey: key) }
        )
    }

    public static var noop: Self {
        Self(
            load: { nil },
            save: { _ in }
        )
    }

    public static var failing: Self {
        Self(
            load: {
                XCTFail("\(Self.self).load not implemented")
                return nil
            },
            save: { _ in XCTFail("\(Self.self).save not implemented") }
        )
    }

}

private func saveValue<Value>(
    _ value: Value?, forKey key: String,
    in directory: FileManager.SearchPathDirectory = .documentDirectory
) where Value: Codable {
    let url = getDirectoryURL(directory).appendingPathComponent(key)

    guard let value = value else {
        try? FileManager.default.removeItem(at: url)
        return
    }

    do {
        let data = try JSONEncoder().encode(value)
        try data.write(to: url, options: .atomic)
    } catch {
        print("did not write to url \(url.absoluteString) due to: \(error)")
    }
}

private func loadValue<Value>(
    forKey key: String, in directory: FileManager.SearchPathDirectory = .documentDirectory
) -> Value? where Value: Codable {
    let path = getDirectoryURL(directory).appendingPathComponent(key)
    do {
        let data = try Data(contentsOf: path)
        return try JSONDecoder().decode(Value.self, from: data)
    } catch {
        print("\(#function) No value decoded for key: \(key) error: \(error.localizedDescription)")
        return nil
    }
}

func saveValue<Value>(
    _ value: Value, forKey key: String, in _: FileManager.SearchPathDirectory = .documentDirectory,
    isSecure: Bool = false
) where Value: NSCoding {
    let path = getDirectoryURL(.documentDirectory).appendingPathComponent(key)

    do {
        let data = try NSKeyedArchiver.archivedData(
            withRootObject: value, requiringSecureCoding: isSecure)
        try data.write(to: path, options: .completeFileProtection)
        print("Successfully saved item to \(path)")
    } catch {
        print("\(#function) ERROR: \(error.localizedDescription)")
    }
}

func loadValue<Value>(
    forKey key: String, in _: FileManager.SearchPathDirectory = .documentDirectory
) -> Value? where Value: NSCoding {
    let path = getDirectoryURL(.documentDirectory).appendingPathComponent(key)
    do {
        let data = try Data(contentsOf: path)
        if let value = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Value {
            print("Found value of type \(Value.self) at path: \(path)")
            return value
        }
        print("Did not find value of type \(Value.self)")
        return nil
    } catch {
        print("\(#function) ERROR: \(error.localizedDescription)")
        return nil
    }
}

func getDirectoryURL(_ type: FileManager.SearchPathDirectory) -> URL {
    let paths = FileManager.default.urls(for: type, in: .userDomainMask)
    return paths[0]
}
