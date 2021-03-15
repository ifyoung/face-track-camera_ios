import UIKit

class SettingController: UIViewController,UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        AppDelegateMain?.window?.currentViewController()?.navigationController?.interactivePopGestureRecognizer?.delegate = self

        if(!Global.isIphoneX()){
            topHeight.constant = 50
        }
        if let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            verLabel.text = "V " + currentAppVersion + "." + build!
        }
        if(Global.getLocalData(nameKey: "soundSwitchAction") == "off"){
//            self.soundImg
            self.soundSwitch.isOn = false
        }else{
            self.soundSwitch.isOn = true

        }
        soundImg.image = soundSwitch.isOn ? UIImage.init(named: "sound_on") : UIImage.init(named: "sound_off")
   
        privacyView.addTapGestureRecognizer { (tap) in
            self.view.privacyDialog(isFirst: false)

        }
    
    }
    @IBOutlet weak var topHeight: NSLayoutConstraint!
    @IBOutlet weak var soundImg: UIImageView!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var verLabel: UILabel!
    @IBOutlet weak var privacyView: UIView!
    @IBAction func back(_ sender: Any) {
        AppDelegateMain?.window?.currentViewController()?.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func soundSwitchAction(_ sender: Any) {
        soundImg.image = soundSwitch.isOn ? UIImage.init(named: "sound_on") : UIImage.init(named: "sound_off")
        
//        NotificationCenter.default.post(name: .SoundSet, object: soundSwitch.isOn)
        Global.saveLocal(soundSwitch.isOn ? "on" : "off", nameKey: "soundSwitchAction")
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

