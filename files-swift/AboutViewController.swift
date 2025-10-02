import UIKit

class AboutViewController: UITableViewController {
    
    let aboutItems = [
        ("iOS越狱交流群", "1030152896"),
        ("创作者AD", "3897069329"),
        ("创作者AD(备用QQ号)", "1107154510"),
        ("Telegraph频道", "https://t.me/adsukisuultra"),
        ("向开发者反馈", "3897069329\n1107154510"),
        ("邮箱", "3897069329@qq.com\n1107154510@qq.com"),
        ("hello", "这是我第三天写iOS的应用程序")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "关于"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "AboutCell")
        tableView.isScrollEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aboutItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "AboutCell")
        let item = aboutItems[indexPath.row]
        
        cell.textLabel?.text = item.0
        cell.detailTextLabel?.text = item.1
        cell.detailTextLabel?.numberOfLines = 0
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = aboutItems[indexPath.row]
        UIPasteboard.general.string = item.1
        
        let alert = UIAlertController(title: "已复制", message: "\(item.0) 已复制到剪贴板", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}