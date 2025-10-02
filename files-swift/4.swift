import UIKit

extension FileListViewController {
    // 創建文件夾
    func createFolder(named folderName: String) {
        let newPath = (currentPath as NSString).appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(atPath: newPath, 
                                                   withIntermediateDirectories: true)
            loadDirectoryContents()
        } catch {
            showErrorAlert(message: "創建文件夾失敗: \(error.localizedDescription)")
        }
    }
    
    // 創建文件
    func createFile(named fileName: String) {
        let newPath = (currentPath as NSString).appendingPathComponent(fileName)
        
        if FileManager.default.createFile(atPath: newPath, contents: nil) {
            loadDirectoryContents()
        } else {
            showErrorAlert(message: "創建文件失敗")
        }
    }
    
    // 刪除文件/文件夾
    func deleteItem(at indexPath: IndexPath) {
        let fileItem = fileItems[indexPath.row]
        
        do {
            try FileManager.default.removeItem(atPath: fileItem.path)
            fileItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        } catch {
            showErrorAlert(message: "刪除失敗: \(error.localizedDescription)")
        }
    }
    
    // 重命名
    func renameItem(_ item: FileItem, to newName: String) {
        let newPath = (currentPath as NSString).appendingPathComponent(newName)
        
        do {
            try FileManager.default.moveItem(atPath: item.path, toPath: newPath)
            loadDirectoryContents()
        } catch {
            showErrorAlert(message: "重命名失敗: \(error.localizedDescription)")
        }
    }
}