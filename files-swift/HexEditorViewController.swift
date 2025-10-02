import UIKit

class HexEditorViewController: UIViewController {
    var filePath: String!
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadHexContent()
    }
    
    private func setupUI() {
        textView = UITextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textView.isEditable = false
        textView.font = UIFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        view.addSubview(textView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(goBack))
    }
    
    private func loadHexContent() {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            showErrorAlert(message: "無法讀取文件")
            return
        }
        
        var hexString = ""
        for (index, byte) in data.enumerated() {
            if index % 16 == 0 {
                hexString += String(format: "%08X: ", index)
            }
            hexString += String(format: "%02X ", byte)
            
            if index % 16 == 15 || index == data.count - 1 {
                // 填充對齊
                let remaining = 15 - (index % 16)
                if remaining > 0 {
                    hexString += String(repeating: "   ", count: remaining)
                }
                
                // 添加ASCII顯示
                let start = index - (index % 16)
                let end = min(start + 15, data.count - 1)
                hexString += " "
                
                for i in start...end {
                    let byte = data[i]
                    if byte >= 32 && byte <= 126 {
                        hexString += String(format: "%c", byte)
                    } else {
                        hexString += "."
                    }
                }
                hexString += "\n"
            }
        }
        
        textView.text = hexString
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
}