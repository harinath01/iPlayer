import UIKit

class ViewController: UIViewController {
    @IBAction func handleNonDRMButtonClick(_ sender: Any) {
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.url = URL(string: Constants.Videos.NON_DRM_PROTECTED_VIDEO)
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: false)
    }
    
    @IBAction func handleDRMButtonClick(_ sender: Any) {
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.url = URL(string: Constants.Videos.DRM_PROTECTED_VIDEO1)
        playerViewController.DRMLicenseURL = Constants.DRM_LICENSE_URL1
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: false)
    }
    
    @IBAction func handleDRMButton2Click(_ sender: Any) {
        let playerViewController = self.storyboard?.instantiateViewController(withIdentifier: "PlayerViewController") as! PlayerViewController
        playerViewController.url = URL(string: Constants.Videos.DRM_PROTECTED_VIDEO2)
        playerViewController.DRMLicenseURL = Constants.DRM_LICENSE_URL2
        playerViewController.modalPresentationStyle = .fullScreen
        self.present(playerViewController, animated: false)
    }
}

