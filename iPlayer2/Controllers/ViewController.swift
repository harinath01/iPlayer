import UIKit

class ViewController: UIViewController {
    @IBAction func handleNonDRMButtonClick(_ sender: Any) {
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: false)
    }
    
    @IBAction func handleDRMButtonClick(_ sender: Any) {
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: false)
    }
}

