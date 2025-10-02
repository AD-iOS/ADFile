import Foundation

struct FileItem {
    let path: String
    let name: String
    let isDirectory: Bool
    let fileSize: UInt64
    let modificationDate: Date
    let permissions: String
    
    init(path: String) {
        self.path = path
        self.name = (path as NSString).lastPathComponent
        
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue
        
        let attributes = try? FileManager.default.attributesOfItem(atPath: path)
        self.fileSize = attributes?[.size] as? UInt64 ?? 0
        self.modificationDate = attributes?[.modificationDate] as? Date ?? Date()
        
        // 获取文件权限
        self.permissions = FileItem.getFilePermissions(path: path)
    }
    
    private static func getFilePermissions(path: String) -> String {
        var statInfo = stat()
        if stat(path, &statInfo) == 0 {
            let permissions = statInfo.st_mode
            return String(format: "%o", permissions & 0o777)
        }
        return "755" // 默认权限
    }
    
    var isHidden: Bool {
        return name.hasPrefix(".")
    }
    
    var displayName: String {
        return isHidden ? "\(name) (隐藏)" : name
    }
}