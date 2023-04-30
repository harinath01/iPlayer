
import UIKit

class PlayerViewController: UIViewController {
    var playerView: VideoPlayerView!
    
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
            url: URL(string: Constants.Videos.NON_DRM_PROTECTED_VIDEO),
            DRMLicenseURL: nil
        )
    }
    
    @IBAction func handleBack(_ sender: Any) {
        dismiss(animated: false)
    }
}
