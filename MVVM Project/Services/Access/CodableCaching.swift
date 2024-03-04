//
//  CodableCaching.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 27.10.2022.
//

import Foundation

/// Simple json caching storage, where each model is translated into json before saving
/// or viceversa
actor CodableCaching<T> {
    
    private let fileManager: FileManager = .default
    
    static var rootDirectory: String {
        return "Imobiliare"
    }
    static var relativePath: NSString {
        let dirPath = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)[0] as NSString
        return dirPath.appendingPathComponent(Self.rootDirectory) as NSString
    }
    
    let filePath: String
    var fileName: String {
        return (filePath as NSString).lastPathComponent
    }
    
    init(resourceID: String) {
        self.filePath = Self.relativePath.appendingPathComponent(resourceID).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
    }
    
    static func deleteCachingDirectory() {
        do {
            try FileManager.default.removeItem(atPath: Self.relativePath as String)
        } catch let error as NSError {
            print("CodableCaching: Failed to delete file \(Self.relativePath)\n\(error)")
        }
    }
}

extension CodableCaching where T: Codable {
    
    /// load json file from disk and tranlate into an mappable object
    func loadFromFile() -> T? {
        let path = filePath as String
        do {
            if let jsonData = try loadContentFromFile() {
                return try JSONDecoder().decode(T.self, from: jsonData)
            }
        } catch let error as NSError {
            print("Failed to load JSON \(path)\n\(error)")
        }
        return nil
    }
    
    /// will save object as json file on disk
    /// - on nil --> file is deleted
    func saveToFile(_ object: T?) {
        guard let object else {
            removeFile(path: filePath)
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(object)
            try saveToFile(data: jsonData)
        }  catch let error as NSError {
            print("CodableCaching: ERROR saving: \(error)")
        }
    }
}

fileprivate extension CodableCaching {
    
    func loadContentFromFile() throws -> Data? {
        if fileManager.fileExists(atPath: filePath) == false {
            return nil
        }
        return try Data(contentsOf: URL(fileURLWithPath: filePath))
    }
    
    /// Note: This mehtod will crewate a directory if necessary
    func saveToFile(data: Data) throws {
        let filePath = self.filePath as NSString
        if fileManager.fileExists(atPath: filePath.deletingLastPathComponent) == false {
            try fileManager.createDirectory(
                atPath: filePath.deletingLastPathComponent,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        try data.write(to: URL(fileURLWithPath: self.filePath))
    }
    
    func removeFile(path: String) {
        do {
            try fileManager.removeItem(atPath: path as String)
        } catch let error as NSError {
            print("CodableCaching: Failed to delete file \(path)\n\(error)")
        }
    }
}
