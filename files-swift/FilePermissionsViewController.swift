// FilePermissionsViewController.swift
import UIKit

// 声明 C 函数
@_cdecl("execute_chmod")
func execute_chmod(_ mode: UnsafePointer<CChar>?, _ path: UnsafePointer<CChar>?) -> Int32 {
    return -1
}

@_cdecl("execute_chown")
func execute_chown(_ owner_group: UnsafePointer<CChar>?, _ path: UnsafePointer<CChar>?) -> Int32 {
    return -1
}

class FilePermissionsViewController: UITableViewController {
    var fileItem: FileItem!
    var filePath: String!
    
    private var permissions: String = "755"
    private var owner: String = "root"
    private var group: String = "wheel"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFileInfo()
    }
    
    private func setupUI() {
        title = "文件权限"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldCell")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(savePermissions))
    }
    
    private func loadFileInfo() {
        // 获取文件权限信息
        var statInfo = stat()
        if stat(filePath, &statInfo) == 0 {
            permissions = String(format: "%o", statInfo.st_mode & 0o777)
            
            // 获取所有者信息
            if let ownerName = getUsername(uid: statInfo.st_uid) {
                owner = ownerName
            }
            
            // 获取组信息
            if let groupName = getGroupname(gid: statInfo.st_gid) {
                group = groupName
            }
        }
        
        tableView.reloadData()
    }
    
    private func getUsername(uid: uid_t) -> String? {
        if let passwd = getpwuid(uid) {
            return String(cString: passwd.pointee.pw_name)
        }
        return nil
    }
    
    private func getGroupname(gid: gid_t) -> String? {
        if let group = getgrgid(gid) {
            return String(cString: group.pointee.gr_name)
        }
        return nil
    }
    
    @objc private func savePermissions() {
        // 使用 C 函数执行 chmod 和 chown
        let chmodResult = permissions.withCString { modePtr in
            filePath.withCString { pathPtr in
                execute_chmod(modePtr, pathPtr)
            }
        }
        
        let ownerGroup = "\(owner):\(group)"
        let chownResult = ownerGroup.withCString { ownerPtr in
            filePath.withCString { pathPtr in
                execute_chown(ownerPtr, pathPtr)
            }
        }
        
        if chmodResult == 0 && chownResult == 0 {
            showSuccessAlert(message: "权限修改成功")
        } else {
            showErrorAlert(message: "权限修改失败")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "权限"
            cell.textField.text = permissions
            cell.textField.placeholder = "例如: 755"
            cell.textFieldDidChange = { [weak self] text in
                self?.permissions = text ?? "755"
            }
        case 1:
            cell.textLabel?.text = "所有者"
            cell.textField.text = owner
            cell.textField.placeholder = "例如: root"
            cell.textFieldDidChange = { [weak self] text in
                self?.owner = text ?? "root"
            }
        case 2:
            cell.textLabel?.text = "组"
            cell.textField.text = group
            cell.textField.placeholder = "例如: wheel"
            cell.textFieldDidChange = { [weak self] text in
                self?.group = text ?? "wheel"
            }
        default:
            break
        }
        
        return cell
    }
    
    private func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "成功", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}

class TextFieldTableViewCell: UITableViewCell {
    let textField = UITextField()
    var textFieldDidChange: ((String?) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textAlignment = .right
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 100)
        ])
    }
    
    @objc private func textFieldChanged() {
        textFieldDidChange?(textField.text)
    }
}