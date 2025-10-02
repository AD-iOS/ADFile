import UIKit

class UpdateLogViewController: UITableViewController {
    
    let updateLogs = [
        "1.6 - 尝试修复/var/jb越狱目录无法创建文件和文件夹的问题但是未能解决,但是疑惑的是/var却可以创建文件和文件夹,因此可能是其他原因导致的",
        "1.5 - 修复部分bug",
        "1.4 - 添加图片浏览器、PDF阅读器、媒体播放器、十六进制编辑器，支持显示隐藏文件和文件权限|去掉清空缓存的功能因为文件管理器貌似不需要",
        "1.3 - 修复部分人因为缺少动态库导致无法启动应用的情况，目前自带动态库",
        "1.2 - 添加文件夹/文件创建支持",
        "1.1 - 添加打开文件夹/文件支持", 
        "1.0 - 初始版本，基础文件管理功能"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "更新日志"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UpdateCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updateLogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath)
        cell.textLabel?.text = updateLogs[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}