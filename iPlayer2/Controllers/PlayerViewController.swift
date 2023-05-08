
import UIKit

class PlayerViewController: UIViewController {
    var playerView: VideoPlayerView!
    var url: URL!
    var DRMLicenseURL: String!
    
    
    @IBOutlet weak var playerContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlayerView()
        playerContainer.removeFromSuperview()
        view.addSubview(playerView)
    }
    
    func initPlayerView(){
        playerView = VideoPlayerView(
            frame: playerContainer.frame,
            url: self.url,
            DRMLicenseURL: self.DRMLicenseURL
        )
    }
    
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: false)
    }
}
