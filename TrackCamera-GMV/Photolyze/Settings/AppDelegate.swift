//
//  AppDelegate.swift
//  Photolyze
//
//  Created by Mac on 05.09.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    func GetUDID() {
        
        let deviceSelector = Selector("openUDIDString")
        
        guard
            let cls = NSClassFromString("UMANUtil"),
            let deviceID = (cls as? NSObjectProtocol)?.perform(deviceSelector).takeUnretainedValue() as? String,
            let jsonData = try? JSONSerialization.data(withJSONObject: ["oid": deviceID], options: JSONSerialization.WritingOptions.prettyPrinted)
            else {
                NSLog("UMengUDIDGetter: Can't get UDID.")
                return
        }
        if(!deviceID.isEmpty){
            Global.saveBleName(deviceID, nameKey: "suitId")//设备唯一标示
        }else{
            Global.saveBleName("Can't get UDID", nameKey: "suitId")//设备唯一标示
            
        }
        NSLog("识别码%@", String(data: jsonData, encoding: String.Encoding.utf8)!)
    }
    func initUmSDK(){
       
        let obj=UMAnalyticsConfig.init();
        obj.appKey="xxxxxxx";
        MobClick.start(withConfigure: obj);
        let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        MobClick.setAppVersion(version)
        MobClick.setLogEnabled(true)
        GetUDID()
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isIdleTimerDisabled = true
        //        engineMain = ArcSoftFaceEngine.init()
        //        testHttp()
        // Initialize the face detector.
        //         NSDictionary *options = @{
        //           GMVDetectorFaceMinSize : @(0.3),
        //           GMVDetectorFaceTrackingEnabled : @(YES),
        //           GMVDetectorFaceLandmarkType : @(GMVDetectorFaceLandmarkAll)
        //         };
//        let options: [AnyHashable: Any] = [
//            GMVDetectorFaceTrackingEnabled: NSNumber(booleanLiteral: true),
//            GMVDetectorFaceMode: NSNumber(integerLiteral: GMVDetectorFaceModeOption.fastMode.rawValue),
//            GMVDetectorFaceLandmarkType: NSNumber(integerLiteral: GMVDetectorFaceLandmark.all.rawValue),
//            GMVDetectorFaceClassificationType: NSNumber(integerLiteral: GMVDetectorFaceClassification.all.rawValue),
//            GMVDetectorFaceMinSize: NSNumber(floatLiteral: 0.35)
//        ]
//        faceDetector = GMVDetector.init(ofType: GMVDetectorTypeFace, options:options)
        
        initUmSDK()
        ARC_active = !Global.getLocalData(nameKey: "ARC_active").isEmpty
        
        DGLocalization.sharedInstance.startLocalization()
        /**
         放引导页后面
         */
        //      let engine = ArcSoftFaceEngine.init()
        //      //   90114-> SDK已激活，无需再次激活；90115->未激活
        //      let resActive = engine.active(withAppId: ASF_APPID, sdkKey: ASF_SDKKEY)
        //        ARC_active = resActive.description.contains("90114") || resActive.description.contains("200")
        //        print("ArcSoftFaceEngine\(resActive)>>")
        
        
        // Override point for customization after application launch.
        //        launch(UINavigationController(rootViewController: SettingController()))
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "switch")
        launch(mainVC)
        
        //创建App窗口
        //               self.window = UIWindow(frame: UIScreen.main.bounds)
        //               self.window?.backgroundColor = UIColor.orange
        //               self.window?.makeKeyAndVisible()
        // 测试界面
        //               let testVC = TestViewController(nibName:"TestViewController", bundle: nil)
        //               let testNVC = BaseNavigationViewController(rootViewController: testVC)
        
        
        
        //        self.window?.rootViewController = MainExController()
        //
        //               //在当前的window上显示引导页视图
        //               if (GuideView.needShowGuideView()) {
        //                   let guideImages = ["guideImg0","guideImg1","guideImg2","guideImg3"]
        //                   let guideView = GuideView(images: guideImages, viewType:.GuideViewStyle_DisapperForClick)
        //                   guideView.showGuideViewToCurrentWindow()
        //               }
        
        return true
    }
  public func launch(_ viewController: UIViewController) {
        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        AppDelegateMain = self
        //           window?.rootViewController = viewController
        let main = UINavigationController(rootViewController: viewController)
        main.setNavigationBarHidden(true, animated: false)
        window?.rootViewController = main
        window?.makeKeyAndVisible()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    //        return [.landscapeRight,.landscapeLeft, .portrait]
    //    }
    //唤醒一下网络
    //    (void)testHttp {
    //        NSURL* url = [NSURL URLWithString:@"https://ai.arcsoft.com.cn"];
    //        NSURLRequest* request = [NSURLRequest requestWithURL:url];
    //        NSURLSession* session = [NSURLSession sharedSession];
    //        NSURLSessionDataTask* dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * data, NSURLResponse * response, NSError * error) {
    //        }];
    //        [dataTask resume];
    //    }
    func testHttp(){
        AFHTTPSessionManager.init().securityPolicy.allowInvalidCertificates = true
        let request =  URLRequest.init(url: URL.init(string: "https://www.baidu.com")!)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request)
        dataTask.resume()
        
    }
    
    
}

