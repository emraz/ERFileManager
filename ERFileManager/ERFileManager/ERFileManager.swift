//
//  ERFileManager.swift
//  ERFileManager
//
//  Created by Mahmudul Hasan on 2020/7/27.
//  Copyright © 2020 Matrix Solution Ltd. All rights reserved.
//

import Foundation

enum FileType :String {
    case Movie = "mov"
    case MP4 = "mp4"
    case MPEG = "mpg"
    case JPEG = "jpg"
    case PNG = "png"
    case GIF = "gif"
    case MP3 = "mp3"
    case WAV = "wav"
    case TEXT = "txt"
    case PDF = "pdf"
    case DOC = "doc"
    case DOCX = "docx"
}

class ERFileManager: NSObject {
    
    static let sharedInstance = ERFileManager ()
    
    func writeItem(directory: URL, fileName: String, fileExtension: String, filedata: Data) -> Bool {
        
        var isSuccess = false
        let fileUrl = directory.appendingPathComponent(fileName).appendingPathExtension(fileExtension)
        //print(fileUrl)
        
        if !self.isExistDirectory(directory: directory.path) {
            
            if self.createDirectory(atPath: directory.path, skipBackup: true) {
                if self.writefiletopath(atPath: fileUrl, imageData: filedata) {
                    isSuccess = true
                }
            }
        } else {
            if self.writefiletopath(atPath: fileUrl, imageData: filedata) {
                isSuccess = true
            }
        }
        return isSuccess
    }
    
    func moveItem(sourcePath: String, destPath: String, isOverWrite: Bool) -> Bool {
        
        if !self.isExistDirectory(directory: destPath) {
            _ = self.createDirectory(atPath: destPath, skipBackup: true)
        }
        
        if self.moveItem(destPath: destPath, sourcePath: sourcePath, isoverwrite: isOverWrite) {
            return true
        } else {
            return false
        }
    }
    
    func copyItem(sourcePath: String, destPath: String, isOverWrite: Bool) -> Bool {
        
        if !self.isExistDirectory(directory: destPath) {
            _ = self.createDirectory(atPath: destPath, skipBackup: true)
        }
        
        if self.copyItem(destPath: destPath, sourcePath: sourcePath, isoverwrite: isOverWrite) {
            return true
        } else {
            return false
        }
    }
    
    func renameItem(exisitngURL: URL, newName: String) -> Bool {
        
        var success = false
        var rv = URLResourceValues()
        rv.name = newName
        var url = exisitngURL
        do {
            try url.setResourceValues(rv)
            success = true
        } catch {
            print(error.localizedDescription)
            success = false
        }
        return success
    }
    
    //  flags URL to exclude from backup
    func addSkipBackupAttributeToItem(atURL: URL) -> Bool {
        var success = false
        var url = atURL
        do {
            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try url.setResourceValues(resourceValues)
            success = true
        } catch {
            print("failed to set resource value")
            success = false
        }
        return success
    }
    
    func getPathFor(directoryType: FileManager.SearchPathDirectory, subDirectory: String?) -> String? {
        let url = self.getURLFor(directoryType: directoryType, subDirectory: subDirectory)
        return url?.path
    }
    
    func getURLFor(directoryType: FileManager.SearchPathDirectory, subDirectory: String?) -> URL? {
        
        let documentUrl = FileManager.default.urls(for: directoryType, in: .userDomainMask).last
        return documentUrl?.appendingPathComponent(subDirectory ?? "")
    }
    
    func getPathForMainBundleFileName(filename: String?) -> String? {
        return URL(fileURLWithPath: Bundle.main.resourcePath ?? "").appendingPathComponent(filename ?? "").absoluteString
    }
    
    func getURLForMainBundleResource(filename: String?, fileExtension: String?) -> URL? {
        return Bundle.main.url(forResource: filename, withExtension: fileExtension)
    }
    
    func getResourceUrl(tag: String?) -> URL? {
        var destinationUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        destinationUrl = destinationUrl?.appendingPathComponent("Downloads")
        destinationUrl = destinationUrl?.appendingPathComponent(tag ?? "")
        return destinationUrl
    }
    
    func getFilesFromMainBundle(folderName: String) -> [String]?{
        
        let srcPath = Bundle.main.resourceURL!.appendingPathComponent(folderName).path
        
        var files: [String]? = nil
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: srcPath)
        } catch {
        }
        
        return files
    }
    
    func getFilesFromDirectory(srcPath: String) -> [String]? {
        
        var files: [String]? = nil
        do {
            files = try FileManager.default.contentsOfDirectory(atPath: srcPath)
        } catch {
        }
        
        return files
    }
    
    private func isExistDirectory(directory: String?) -> Bool {
        
        if FileManager.default.fileExists(atPath: directory ?? "") == false {
            
            return false
        }
        return true
    }
    
    private func createDirectory(atPath: String, skipBackup: Bool) -> Bool {
        
        var isSuccess = false
        
        do {
            try FileManager.default.createDirectory(atPath: atPath, withIntermediateDirectories: true, attributes: nil)
            isSuccess = true
        } catch {
            print(error.localizedDescription);
            isSuccess = false
        }
        
        if isSuccess && skipBackup {
            let url = URL(fileURLWithPath: atPath)
            _ = self.addSkipBackupAttributeToItem(atURL: url)
        }
        
        return isSuccess
    }
    
    private func copyItem(destPath: String, sourcePath: String, isoverwrite: Bool) -> Bool {
        
        var isSuccess = false
        
        if !isoverwrite {
            // not allowed to overwrite files - remove destination file
            do {
                try FileManager.default.removeItem(atPath: destPath)
            } catch {
            }
        }
        
        
        do {
            try FileManager.default.copyItem(atPath: sourcePath, toPath: sourcePath)
            isSuccess = true
            
        } catch {
            print("Unable to copy file")
            isSuccess = false
        }
        return isSuccess
    }
    
    private func moveItem(destPath: String, sourcePath: String, isoverwrite: Bool) -> Bool {
        var isSuccess = false
        
        if !isoverwrite {
            // not allowed to overwrite files - remove destination file
            do {
                try FileManager.default.removeItem(atPath: destPath)
            } catch {
                print("Unable to remove file")
            }
        }
        
        do {
            try FileManager.default.moveItem(atPath: sourcePath, toPath: destPath)
            isSuccess = true
        } catch {
            print("Unable to copy file")
            isSuccess = false
        }
        
        return isSuccess
        
    }
    
    func deleteItem(atPath: String) -> Bool {
        var isSuccess = false
        do {
            try FileManager.default.removeItem(atPath: atPath)
            print("Success: delete item to destination folder; \(atPath)")
            isSuccess = true
        } catch {
            print("Error: unable to delete item: \(error)")
            isSuccess = false
        }
        return isSuccess
    }
    
    private func writefiletopath(atPath: URL, imageData: Data) -> Bool {
        var isSuccess = false
        do {
            try imageData.write(to: atPath)
            print("data written")
            isSuccess = true
        } catch {
            print(error)
            isSuccess = false
        }
        return isSuccess;
    }
}



