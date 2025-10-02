import UIKit
import Foundation

// 声明 C 函数 - 使用 extern 方式
@_cdecl("execute_zip")
func execute_zip(_ is_directory: Int32, _ source: UnsafePointer<CChar>?, _ dest: UnsafePointer<CChar>?) -> Int32 {
    // 这里只是声明，实现在 C 代码中
    return -1
}

@_cdecl("execute_unzip")  
func execute_unzip(_ zip_path: UnsafePointer<CChar>?, _ extract_path: UnsafePointer<CChar>?) -> Int32 {
    // 这里只是声明，实现在 C 代码中
    return -1
}

extension FileListViewController {
    func compressItem(_ item: FileItem) {
        let source = item.path
        let dest = (currentPath as NSString).appendingPathComponent("\(item.name).zip")
        
        print("Compressing: \(source) to \(dest)")
        print("Item is directory: \(item.isDirectory)")
        
        let result = source.withCString { sourcePtr in
            dest.withCString { destPtr in
                execute_zip(item.isDirectory ? 1 : 0, sourcePtr, destPtr)
            }
        }
        
        print("Compression result: \(result)")
        
        if result == 0 {
            self.loadDirectoryContents()
            self.showSuccessAlert(message: "压缩成功")
        } else {
            self.showErrorAlert(message: "压缩失败，错误码: \(result)")
        }
    }
    
    func decompressItem(_ item: FileItem) {
        let source = item.path
        let dest = currentPath
        
        let result = source.withCString { sourcePtr in
            dest.withCString { destPtr in
                execute_unzip(sourcePtr, destPtr)
            }
        }
        
        if result == 0 {
            self.loadDirectoryContents()
            self.showSuccessAlert(message: "解压成功")
        } else {
            self.showErrorAlert(message: "解压失败，错误码: \(result)")
        }
    }
    
    // 删除这里的 showSuccessAlert 方法，因为它已经在 1.swift 中定义了
}