import UIKit

class SettingsViewController: UITableViewController {
    
    weak var fileListVC: FileListViewController?
    
    let settingsItems = [
        "关于",
        "显示隐藏文件",
        "文件排序方式",
        "更新日志"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "设置"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
    }
    
    @objc private func dismissSettings() {
        dismiss(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.textLabel?.text = settingsItems[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        // 显示隐藏文件开关
        if indexPath.row == 1 {
            let switchView = UISwitch()
            switchView.isOn = fileListVC?.showHiddenFiles ?? false
            switchView.addTarget(self, action: #selector(toggleHiddenFiles(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.selectionStyle = .none
        } else {
            cell.accessoryView = nil
            cell.selectionStyle = .default
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            showAboutPage()
        case 2:
            showSortOptions()
        case 3:
            showUpdateLog()
        default:
            break
        }
    }
    
    @objc private func toggleHiddenFiles(_ sender: UISwitch) {
        fileListVC?.showHiddenFiles = sender.isOn
        fileListVC?.loadDirectoryContents()
    }
    
    private func showAboutPage() {
        let aboutVC = AboutViewController()
        navigationController?.pushViewController(aboutVC, animated: true)
    }
    
    private func showSortOptions() {
        let alert = UIAlertController(title: "排序方式", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "按名称", style: .default))
        alert.addAction(UIAlertAction(title: "按日期", style: .default))
        alert.addAction(UIAlertAction(title: "按大小", style: .default))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showUpdateLog() {
        let updateLogVC = UpdateLogViewController()
        navigationController?.pushViewController(updateLogVC, animated: true)
    }
}