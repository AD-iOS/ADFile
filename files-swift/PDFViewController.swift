import UIKit
import PDFKit

class PDFViewController: UIViewController {
    var filePath: String!
    var pdfView: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadPDF()
    }
    
    private func setupUI() {
        pdfView = PDFView(frame: view.bounds)
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        view.addSubview(pdfView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(goBack))
    }
    
    private func loadPDF() {
        if let pdfDocument = PDFDocument(url: URL(fileURLWithPath: filePath)) {
            pdfView.document = pdfDocument
        } else {
            showErrorAlert(message: "无法加载PDF文件")
        }
    }
    
    @objc private func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "错误", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default))
        present(alert, animated: true)
    }
}