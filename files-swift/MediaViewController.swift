import UIKit
import AVKit

class MediaViewController: UIViewController {
    var filePath: String!
    var playerViewController: AVPlayerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadMedia()
    }
    
    private func setupUI() {
        playerViewController = AVPlayerViewController()
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(goBack))
    }
    
    private func loadMedia() {
        let fileURL = URL(fileURLWithPath: filePath)
        let player = AVPlayer(url: fileURL)
        playerViewController.player = player
        player.play()
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