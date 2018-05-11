//
// Created by Nominalista on 24.01.2018.
// Copyright (c) 2018 Nominalista. All rights reserved.
//

import Foundation

extension FileManager {

    // Directories

    func cacheDirectoryURL() -> URL? {
        return urls(for: .cachesDirectory, in: .userDomainMask).first
    }

    func documentDirectoryURL() -> URL? {
        return urls(for: .documentDirectory, in: .userDomainMask).first
    }

    // Existence

    func fileExists(at url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }

    func directoryExists(at url: URL) -> Bool {
        var isDirectory = ObjCBool(true)
        return fileExists(atPath: url.path, isDirectory: &isDirectory)
    }

    // File URLs

    func fileURLs(at url: URL, withExtension pathExtension: String? = nil) -> [URL] {
        do {
            let urls = try contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])

            if let pathExtension = pathExtension {
                return urls.filter { url in url.pathExtension == pathExtension }
            } else {
                return urls
            }
        } catch {
            print("Can't get file URLs due to \(error.localizedDescription).")
            return []
        }
    }

    // Create

    func createFile(from data: Data, at url: URL) -> Bool {
        do {
            try data.write(to: url)
            return true
        } catch {
            return false
        }
    }

    func createDirectory(at url: URL) -> Bool {
        do {
            try createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }

    // Delete

    func removeFile(at url: URL) -> Bool {
        do {
            try removeItem(at: url)
            return true
        } catch {
            return false
        }
    }

    func removeDirectory(at url: URL) -> Bool {
        do {
            try removeItem(at: url)
            return true
        } catch {
            return false
        }
    }
}