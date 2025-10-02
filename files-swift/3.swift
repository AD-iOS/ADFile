import UIKit

extension FileListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        let fileItem = fileItems[indexPath.row]
        
        cell.textLabel?.text = fileItem.displayName
        cell.textLabel?.textColor = fileItem.isHidden ? .lightGray : .label
        
        let sizeString = fileItem.isDirectory ? "文件夹" : "\(fileItem.fileSize) bytes"
        let permissionString = "权限: \(fileItem.permissions)"
        cell.detailTextLabel?.text = "\(sizeString) | \(permissionString)"
        
        // 设置图标
        if fileItem.isDirectory {
            cell.imageView?.image = UIImage(systemName: fileItem.isHidden ? "folder.fill" : "folder")
            cell.imageView?.tintColor = fileItem.isHidden ? .lightGray : .systemBlue
        } else {
            cell.imageView?.image = UIImage(systemName: fileItem.isHidden ? "doc.fill" : "doc")
            cell.imageView?.tintColor = fileItem.isHidden ? .lightGray : .label
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileItem = fileItems[indexPath.row]
        
        if fileItem.isDirectory {
            let nextVC = FileListViewController()
            nextVC.currentPath = fileItem.path
            nextVC.showHiddenFiles = self.showHiddenFiles
            navigationController?.pushViewController(nextVC, animated: true)
        } else {
            openFile(fileItem)
        }
    }
    
    // 添加上下文菜单
    override func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let fileItem = fileItems[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let renameAction = UIAction(title: "重命名", image: UIImage(systemName: "pencil")) { _ in
                self.promptForRename(fileItem: fileItem)
            }
            
            let compressAction = UIAction(title: "压缩", image: UIImage(systemName: "archivebox")) { _ in
                self.compressItem(fileItem)
            }
            
            let deleteAction = UIAction(title: "删除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self.deleteItem(at: indexPath)
            }
            
            var actions = [renameAction, compressAction, deleteAction]
            
            if fileItem.name.hasSuffix(".zip") {
                let decompressAction = UIAction(title: "解压缩", image: UIImage(systemName: "arrow.up.bin")) { _ in
                    self.decompressItem(fileItem)
                }
                actions.insert(decompressAction, at: 1)
            }
            
            // 添加权限查看
            let viewPermissionAction = UIAction(title: "查看权限", image: UIImage(systemName: "info.circle")) { _ in
                self.showFilePermissions(fileItem: fileItem)
            }
            
            // 添加权限管理
            let managePermissionAction = UIAction(title: "权限管理", image: UIImage(systemName: "lock")) { _ in
                let permissionVC = FilePermissionsViewController()
                permissionVC.fileItem = fileItem
                permissionVC.filePath = fileItem.path
                self.navigationController?.pushViewController(permissionVC, animated: true)
            }
            
            // 正确插入到 actions 数组中
            actions.insert(managePermissionAction, at: 1) // 权限管理放在第二个位置
            actions.insert(viewPermissionAction, at: 0)   // 查看权限放在第一个位置
            
            return UIMenu(title: fileItem.name, children: actions)
        }
    }
    
    private func promptForRename(fileItem: FileItem) {
        let alert = UIAlertController(title: "重命名", message: "请输入新名称", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = fileItem.name
        }
        
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.renameItem(fileItem, to: newName)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showFilePermissions(fileItem: FileItem) {
        let alert = UIAlertController(title: "文件信息", message: """
            名称: \(fileItem.name)
            路径: \(fileItem.path)
            大小: \(fileItem.fileSize) bytes
            权限: \(fileItem.permissions)
            修改时间: \(fileItem.modificationDate)
            """, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}