import UIKit

class TextEditorViewController: UIViewController {
    var filePath: String!
    var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadFileContent()
    }
    
    private func setupUI() {
        textView = UITextView(frame: view.bounds)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(textView)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(saveFile))
    }
    
    private func loadFileContent() {
        if let content = try? String(contentsOfFile: filePath) {
            textView.text = content
        }
    }
    
    @objc func saveFile() {
        do {
            try textView.text.write(toFile: filePath, atomically: true, encoding: .utf8)
            navigationController?.popViewController(animated: true)
        } catch {
            let alert = UIAlertController(title: "保存失敗", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
        }
    }
}