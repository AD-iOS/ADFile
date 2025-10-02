import UIKit
import AVKit

class FileListViewController: UITableViewController {
    var currentPath: String = "/"
    var fileItems: [FileItem] = []
    var showHiddenFiles: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadDirectoryContents()
        setupNavigationBar()
        updateTitle()
        updateFavoriteButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDirectoryContents()
        updateFavoriteButton()
    }
    
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FileCell")
    }
    
    private func setupNavigationBar() {
    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showCreateMenu))
    let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "star"), style: .plain, target: self, action: #selector(showFavorites))
    let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(showSettings))
    navigationItem.rightBarButtonItems = [addButton, favoriteButton, settingsButton]
    
    // 更新收藏按钮状态
    updateFavoriteButton()
}

private func updateFavoriteButton() {
    let isFavorited = FavoritesManager.shared.isFavorite(path: currentPath)
    let favoriteButton = navigationItem.rightBarButtonItems?[1]
    favoriteButton?.image = UIImage(systemName: isFavorited ? "star.fill" : "star")
    favoriteButton?.tintColor = isFavorited ? .systemYellow : .systemBlue
}

@objc func showFavorites() {
    let isFavorited = FavoritesManager.shared.isFavorite(path: currentPath)
    
    if isFavorited {
        // 如果已经收藏，显示取消收藏选项
        let alert = UIAlertController(title: "收藏目录", message: "选择操作", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "取消收藏", style: .destructive) { _ in
            self.removeFromFavorites()
        })
        
        alert.addAction(UIAlertAction(title: "管理收藏", style: .default) { _ in
            self.showFavoritesManager()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    } else {
        // 如果未收藏，提示添加收藏
        promptForFavoriteName()
    }
}

private func promptForFavoriteName() {
    let alert = UIAlertController(title: "添加收藏", message: "为当前目录设置一个名称", preferredStyle: .alert)
    alert.addTextField { textField in
        textField.placeholder = "收藏名称"
        textField.text = (self.currentPath as NSString).lastPathComponent
    }
    
    alert.addAction(UIAlertAction(title: "添加", style: .default) { _ in
        if let name = alert.textFields?.first?.text, !name.isEmpty {
            self.addToFavorites(name: name)
        }
    })
    
    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
    
    present(alert, animated: true)
}

private func addToFavorites(name: String) {
    FavoritesManager.shared.addFavorite(path: currentPath, name: name)
    updateFavoriteButton()
    showSuccessAlert(message: "已添加到收藏")
}

private func removeFromFavorites() {
    if let favoriteName = FavoritesManager.shared.getFavorites().first(where: { $0.value == currentPath })?.key {
        FavoritesManager.shared.removeFavorite(name: favoriteName)
        updateFavoriteButton()
        showSuccessAlert(message: "已取消收藏")
    }
}

private func showFavoritesManager() {
    let favorites = FavoritesManager.shared.getFavorites()
    let alert = UIAlertController(title: "收藏目录", message: nil, preferredStyle: .actionSheet)
    
    for (name, path) in favorites {
        alert.addAction(UIAlertAction(title: "\(name) - \(path)", style: .default) { _ in
            self.navigateToFavorite(path: path)
        })
    }
    
    alert.addAction(UIAlertAction(title: "取消", style: .cancel))
    
    present(alert, animated: true)
    }

private func navigateToFavorite(path: String) {
    let nextVC = FileListViewController()
    nextVC.currentPath = path
    nextVC.showHiddenFiles = self.showHiddenFiles
    navigationController?.pushViewController(nextVC, animated: true)
    }
    
    private func updateTitle() {
        if currentPath == "/" {
            title = "根目录"
        } else {
            title = (currentPath as NSString).lastPathComponent
        }
        navigationItem.prompt = "路径: \(currentPath)"
    }
    
    func loadDirectoryContents() {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: currentPath)
            var items = contents.map { fileName in
                let fullPath = (currentPath as NSString).appendingPathComponent(fileName)
                return FileItem(path: fullPath)
            }
            
            // 过滤隐藏文件
            if !showHiddenFiles {
                items = items.filter { !$0.name.hasPrefix(".") }
            }
            
            fileItems = items.sorted { item1, item2 in
                if item1.isDirectory && !item2.isDirectory {
                    return true
                } else if !item1.isDirectory && item2.isDirectory {
                    return false
                } else {
                    return item1.name.localizedCaseInsensitiveCompare(item2.name) == .orderedAscending
                }
            }
            
            tableView.reloadData()
            updateTitle()
        } catch {
            print("读取目录失败: \(error)")
            showErrorAlert(message: "无法读取目录: \(error.localizedDescription)")
        }
    }
    
    func openFile(_ fileItem: FileItem) {
        if fileItem.isDirectory {
            let nextVC = FileListViewController()
            nextVC.currentPath = fileItem.path
            nextVC.showHiddenFiles = self.showHiddenFiles
            navigationController?.pushViewController(nextVC, animated: true)
            return
        }
        
        // 显示文件打开选项
        showFileOpenOptions(fileItem)
    }
    
    func showFileOpenOptions(_ fileItem: FileItem) {
        let alert = UIAlertController(title: "打开方式", message: "选择打开 \(fileItem.name) 的方式", preferredStyle: .actionSheet)
        
        let fileExtension = (fileItem.name as NSString).pathExtension.lowercased()
        
        // 总是显示系统打开选项
        alert.addAction(UIAlertAction(title: "系统应用打开", style: .default) { _ in
            self.openWithSystemApp(fileItem)
        })
        
        // 文本文件
        if isTextFile(fileExtension) {
            alert.addAction(UIAlertAction(title: "文本编辑器", style: .default) { _ in
                self.openTextEditor(fileItem)
            })
        }
        
        // 图片文件
        if isImageFile(fileExtension) {
            alert.addAction(UIAlertAction(title: "图片浏览器", style: .default) { _ in
                self.openImageBrowser(fileItem)
            })
        }
        
        // PDF文件
        if fileExtension == "pdf" {
            alert.addAction(UIAlertAction(title: "PDF阅读器", style: .default) { _ in
                self.openPDFViewer(fileItem)
            })
        }
        
        // 媒体文件
        if isMediaFile(fileExtension) {
            alert.addAction(UIAlertAction(title: "媒体播放器", style: .default) { _ in
                self.openMediaPlayer(fileItem)
            })
        }
        
        // 十六进制编辑器（所有文件都可用）
        alert.addAction(UIAlertAction(title: "十六进制编辑器", style: .default) { _ in
            self.openHexEditor(fileItem)
        })
        
        // 压缩文件
        if fileExtension == "zip" {
            alert.addAction(UIAlertAction(title: "解压缩", style: .default) { _ in
                self.decompressItem(fileItem)
            })
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        // 适配iPad
        if let popoverController = alert.popoverPresentationController {
            if let cell = tableView.cellForRow(at: IndexPath(row: fileItems.firstIndex(where: { $0.path == fileItem.path }) ?? 0, section: 0)) {
                popoverController.sourceView = cell
                popoverController.sourceRect = cell.bounds
            }
        }
        
        present(alert, animated: true)
    }
    
    // 文件类型判断方法
    private func isTextFile(_ ext: String) -> Bool {
        let textExtensions = ["txt", "md", "json", "xml", "html", "htm", "css", "js", "py", "java", "c", "cpp", "h", "m", "mm", "swift", "plist", "strings", "log", "sh", "bash", "zsh", "hpp", "rs", "scss", "yml", "yaml", "toml", "mod", "go"]
        return textExtensions.contains(ext)
    }
    
    private func isImageFile(_ ext: String) -> Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp", "heic"]
        return imageExtensions.contains(ext)
    }
    
    private func isMediaFile(_ ext: String) -> Bool {
        let mediaExtensions = ["mp4", "mov", "avi", "mkv", "mp3", "wav", "aac", "m4a"]
        return mediaExtensions.contains(ext)
    }
    
    // 各种打开方式的具体实现
    private func openTextEditor(_ fileItem: FileItem) {
        let textEditor = TextEditorViewController()
        textEditor.filePath = fileItem.path
        textEditor.title = fileItem.name
        navigationController?.pushViewController(textEditor, animated: true)
    }
    
    private func openImageBrowser(_ fileItem: FileItem) {
        let imageViewer = ImageViewController()
        imageViewer.filePath = fileItem.path
        imageViewer.title = fileItem.name
        navigationController?.pushViewController(imageViewer, animated: true)
    }
    
    private func openPDFViewer(_ fileItem: FileItem) {
        let pdfViewer = PDFViewController()
        pdfViewer.filePath = fileItem.path
        pdfViewer.title = fileItem.name
        navigationController?.pushViewController(pdfViewer, animated: true)
    }
    
    private func openMediaPlayer(_ fileItem: FileItem) {
        let mediaPlayer = MediaViewController()
        mediaPlayer.filePath = fileItem.path
        mediaPlayer.title = fileItem.name
        navigationController?.pushViewController(mediaPlayer, animated: true)
    }
    
    private func openHexEditor(_ fileItem: FileItem) {
        let hexEditor = HexEditorViewController()
        hexEditor.filePath = fileItem.path
        hexEditor.title = fileItem.name
        navigationController?.pushViewController(hexEditor, animated: true)
    }
    
    private func openWithSystemApp(_ fileItem: FileItem) {
        let fileURL = URL(fileURLWithPath: fileItem.path)
        
        // 使用 UIDocumentInteractionController 来使用系统应用打开
        let documentController = UIDocumentInteractionController(url: fileURL)
        documentController.delegate = self
        
        if documentController.presentPreview(animated: true) {
            // 预览成功
        } else if documentController.presentOpenInMenu(from: .zero, in: self.view, animated: true) {
            // 显示"在...中打开"菜单
        } else {
            showErrorAlert(message: "没有找到可以打开此文件的应用程序")
        }
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    @objc private func showCreateMenu() {
        let alert = UIAlertController(title: "创建", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "新建文件夹", style: .default) { _ in
            self.promptForFolderName()
        })
        
        alert.addAction(UIAlertAction(title: "新建文件", style: .default) { _ in
            self.promptForFileName()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    @objc private func showSettings() {
        let settingsVC = SettingsViewController()
        settingsVC.fileListVC = self
        let navController = UINavigationController(rootViewController: settingsVC)
        present(navController, animated: true)
    }
    
    private func promptForFolderName() {
        let alert = UIAlertController(title: "新建文件夹", message: "请输入文件夹名称", preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "创建", style: .default) { _ in
            if let folderName = alert.textFields?.first?.text, !folderName.isEmpty {
                let sanitizedName = folderName.replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "\\", with: "_")
                    .replacingOccurrences(of: ":", with: "_")
                
                if sanitizedName != folderName {
                    self.showErrorAlert(message: "文件夹名称包含非法字符，已自动替换")
                }
                
                self.createFolder(named: sanitizedName)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func promptForFileName() {
        let alert = UIAlertController(title: "新建文件", message: "请输入文件名称", preferredStyle: .alert)
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "创建", style: .default) { _ in
            if let fileName = alert.textFields?.first?.text, !fileName.isEmpty {
                let sanitizedName = fileName.replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "\\", with: "_")
                    .replacingOccurrences(of: ":", with: "_")
                
                if sanitizedName != fileName {
                    self.showErrorAlert(message: "文件名称包含非法字符，已自动替换")
                }
                
                self.createFile(named: sanitizedName)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}

// 添加 UIDocumentInteractionControllerDelegate 扩展
extension FileListViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}