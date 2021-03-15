//
//  MainExController.swift
//  lc_facecamera
//
//  Created by LCh on 2020/5/31.
//  Copyright © 2020 Lammax. All rights reserved.
//

import Foundation
import SPPermissions


protocol PhotoSceneDisplayLogic: class {
    func displaySavePhoto(viewModel: PhotoScene.StoreCall.ViewModel)
    func displayStorePhoto(viewModel: PhotoScene.StorePhoto.ViewModel)
}
@objc protocol SlideAnimeShowDelegate {
    @objc func showSlide(isOpen:Bool)
}


typealias NearbyPeripheralInfos = [CBPeripheral:Dictionary<String, AnyObject>]

typealias onACTION_CONFIRM = (Bool) -> Void

class MainExController: UIViewController,SPPermissionsDataSource, SPPermissionsDelegate{
    
    
    var onAction_Confirm:onACTION_CONFIRM?
    
    //蓝牙属性
    var manager: CBCentralManager!
    var peripheralTemp: CBPeripheral!
    var writeCharacteristic: CBCharacteristic!
    var readCharacteristic: CBCharacteristic!
    
    let defaultCenter = NotificationCenter.default
    
    var connectingPeripheral:CBPeripheral?
    var connectionLongTimer:Timer?
    var connectionNoDataTimer:Timer?
    var scanTimer:Timer?
    var scanRISSTimer:Timer?//后台信号与列表
    //保存收到的蓝牙设备
    var deviceList:NSMutableArray = NSMutableArray()
    //服务和特征的UUID
    let kServiceUUID = CBUUID(string: "\(BLEServiceSearchUUID)")
    let kServiceConnectUUID = CBUUID(string: "\(BLEServiceConnectUUID)")
    
    var timerTest:Timer?
    
    
    //    let kCharacteristicUUID = [CBUUID(string:"\(BLECharacteristicUUID_WRITE)")]
    
    typealias GetLatestImg = ((SPPermission?) -> Void)
    
    //    var deviceList_RISS:NSMutableArray = NSMutableArray()
    var nearbyPeripheralInfos : NearbyPeripheralInfos = NearbyPeripheralInfos()
    
    
    var isCameraDenied = true
    
    var slideDelegate:SlideAnimeShowDelegate?
    
    
    override func viewDidLoad() {
        slideDelegate = self
        //        //在当前的window上显示引导页视图
        if (GuideView.needShowGuideView()) {
            let guideImages = ["guideImg0","guideImg1","guideImg2","guideImg3"]
            let guideView = GuideView(images: guideImages, viewType:.GuideViewStyle_DisapperForClick){
                self.slideDelegate?.showSlide(isOpen: true)
                
            }
            //            guideView.alpha = 0.3
            guideView.showGuideViewToSuperView(superView: self.view)
        }
        
        //        if let audioPath = Bundle.main.path(forResource: "dangdang33", ofType: ".m4a"){
        //        try? audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath))
        //
        //        }
        //        do{
        //                   let audioPath = Bundle.main.path(forResource: "dangdang33", ofType: ".m4a")
        //                   try audioPlayer = AVAudioPlayer(contentsOf: URL(fileURLWithPath: audioPath!))
        //               }catch{
        //                   // Error
        //               }
        
        
        
        
        //1.创建一个中央对象,有视图之后
        self.manager = CBCentralManager(delegate: self, queue: nil)
        defaultCenter.addObserver(self, selector: #selector(onSetRenewScan(_:)), name: .SetRenewScan, object: nil)
        defaultCenter.addObserver(self, selector: #selector(onRenewBtnClick), name: .SetReScan, object: nil)
        defaultCenter.addObserver(self, selector: #selector(onSound), name: .SoundSet, object: nil)
        
        defaultCenter.addObserver(self, selector: #selector(onRenewBtnClick), name: .SetReScan, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWifi(_:)), name: .Wifi, object: nil)
        checkPermission()
        frontOrBackListener()
        NetWork.checkUpdateAPP { (res) in
            if(res.contains("update")){
                self.isShowUpdate = true
                self.view.updateAlert {
                    self.isShowUpdate = false
                }
            }
            
        }

    }
    var isShowUpdate = false
    
    
    func isArcActive(){
        if(!ARC_active){
//            DispatchQueue.main.async {
//                SVProgressHUD.showInfo(withStatus: "首次需连上设备联网激活")
//            }
            if(!isShowUpdate){
//                self.view.popTopNotice()
            }
        }
    }
    
    
    //连接状态
    @objc func onWifi(_ no:Notification){
        wifiState = no.object as! Bool
        
    }
    //声音
    @objc func onSound(_ no:Notification){
        
        
    }
    @objc func onRenewBtnClick(){
        if(self.connectingPeripheral != nil){
            self.connect(connectingPeripheral!)
        }else{
            self.bleScan()
        }
    }
    
    @objc func onSetRenewScan(_ no:Notification?){
//        if(no != nil){
//
//        }
            isDeviceCorrect = nil//重置

        
        if(wifiState){
            if(currentPeripheral != nil){
                self.manager.cancelPeripheralConnection(currentPeripheral!)
            }
            bleScan()
            defaultCenter.post(name: .Wifi, object: false)
            defaultCenter.removeObserver(self, name: .Write, object: nil)
            print("onSetRenewScan-Connected")
        }else{
            self.manager = CBCentralManager(delegate: self, queue: nil)
            print("onSetRenewScan-Disconnected")
            
        }
    }
    func bleScan(){
        defaultCenter.post(name: .Wifi, object: false)
        self.deviceList.removeAllObjects()
        
        //扫描周边蓝牙外设.
        //写nil表示扫描所有蓝牙外设，如果传上面的kServiceUUID,那么只能扫描出FFEO这个服务的外设。
        //CBCentralManagerScanOptionAllowDuplicatesKey为true表示允许扫到重名，false表示不扫描重名的。
        //5B50FF1E-03A5-8162-7B40-A3956CD84E8F cuo
        //启动一次scanForPeripherals，相应的CBPeripheral会变nil
        self.manager.scanForPeripherals(withServices: [kServiceUUID], options:[CBCentralManagerScanOptionAllowDuplicatesKey: true])
        //        stopScanTimeLater()
    }
    func stopScanTimeLater(){
        scanTimer=Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(stopScanNow), userInfo: nil, repeats: false)
        print("停止扫描预调用")
    }
    
    func connect(_ device:CBPeripheral){
        //           cleanscanRISSTimer()//连接成功后再取消？
        print("开始链接")
        Global.saveBleName(EMPTYVARCHAR, nameKey: "MagicVer")//重置？
        cleanScanTimer()
        cleanConnectionTimer()
        connectionLongTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(onConnectionLongTime), userInfo: nil, repeats: false)
        self.manager.connect(device, options: nil)
        connectingPeripheral = device
        //    GlobalToast.showToastLoading("progress_dialog_connecting".localize())//链接中
        
    }
    var connectTimes = 3
    var connectTime = 0
    // open func connect(_ peripheral: CBPeripheral, options: [String : Any]? = nil)
    @objc func onConnectionLongTime(){
        //          GlobalToast.hideLoading()
        print("onConnectionLongTime")
        if(connectingPeripheral != nil){
            self.manager.cancelPeripheralConnection(connectingPeripheral!)
        }
        connectTime += 1
        print("onConnectionLongTime___\(connectTime)")
        
        if(connectTime>=connectTimes){
            //              showConnectionLongTimeHint(isToFar: true)//距离太远
            cleanscanRISSTimer()
            cleanScanTimer()
            cleanConnectionTimer()
            connectTime = 0
        }
    }
    func cleanscanRISSTimer(){
        print("测试-cleanscanRISSTimer")
        if(scanRISSTimer != nil){
            
            scanRISSTimer!.invalidate()
            scanRISSTimer = nil
        }
        
        if #available(iOS 9.0, *) {
            if(self.manager != nil && self.manager.isScanning){
                //                self.manager.stopScan()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func stopScanNow(){
        print("伪停止扫描调用")
        //        self.manager.stopScan()
        let saveUUID = Global.getBleUUID()
        if(saveUUID != EMPTYVARCHAR ){
            for device in deviceList{
                if((device as! CBPeripheral).identifier.description == saveUUID ){
                    //苹果手表连接后关机，极有可能导致连接不上（连接超时后重连还是连不上），所以不会要强行停止扫描
                    //                        self.manager.stopScan()
                    connect(device as! CBPeripheral)
                    print("去链接")
                    return
                }
            }
        }
    }
    
    func cleanScanTimer(){
        if(scanTimer != nil){
            scanTimer!.invalidate()
            scanTimer = nil
        }
    }
    
    func cleanConnectionTimer(){
        
        if(connectionLongTimer != nil){
            connectionLongTimer!.invalidate()
            connectionLongTimer = nil
        }
    }
    
    func frontOrBackListener(){
        //注册进入前台的通知
        NotificationCenter.default.addObserver(self, selector:#selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        //注册进入后台的通知
        NotificationCenter.default.addObserver(self, selector:#selector(becomeBack), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(didEnterBack), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    @objc func becomeActive(noti:Notification){
        print("becomeActive")
        if(!wifiState){
            onSetRenewScan(nil)
        }
    }
    @objc func becomeBack(noti:Notification){
        print("becomeBack")}
    
    @objc func didEnterBack(noti:Notification){
        print("becomeBack-didEnterBack")}
    func checkPermission() {
        //        let controller = SPPermissions.dialog([.camera,.photoLibrary])
        //        let controller = SPPermissions.list([.camera,.photoLibrary])
        let controller = SPPermissions.native([.camera,.photoLibrary])
        
        // Ovveride texts in controller
        //        controller.titleText = "完美体验需要您的授权"
        //        controller.headerText = " "
        //        controller.footerText = " "
        //
        //        // Set `DataSource` or `Delegate` if need.
        //        // By default using project texts and icons.
        //        controller.dataSource = self
        controller.delegate = self
        
        // Always use this method for present
        controller.present(on: self)
    }
    
    /**
     权限相关
     */
    /**
     Configure permission cell here.
     You can return permission if want use default values.
     
     - parameter cell: Cell for configure. You can change all data.
     - parameter permission: Configure cell for it permission.
     */
    func configure(_ cell: SPPermissionTableViewCell, for permission: SPPermission) -> SPPermissionTableViewCell {
        
        /*
         // Titles
         cell.permissionTitleLabel.text = "Notifications"
         cell.permissionDescriptionLabel.text = "Remind about payment to your bank"
         cell.button.allowTitle = "Allow"
         cell.button.allowedTitle = "Allowed"
         
         // Colors
         cell.iconView.color = .systemBlue
         cell.button.allowedBackgroundColor = .systemBlue
         cell.button.allowTitleColor = .systemBlue
         
         // If you want set custom image.
         cell.set(UIImage(named: "IMAGE-NAME")!)
         
         // Maybe need set custom color for your custom image
         // For it set rendering mode and set tint color
         cell.iconImageView.tintColor = .systemRed
         */
        
        return cell
    }
    
    /**
     Call when controller closed.
     
     - parameter ids: Permissions ids, which using this controller.
     */
    func didHide(permissions ids: [Int]) {
        //        var tempPermissions = [SPPermission]()
        var tempPermissions = [String]()
        let permissions = ids.map { SPPermission(rawValue: $0)! }
        
        print("Did hide with permissions: ", permissions.map { $0.isDenied },permissions.map { $0.isAuthorized },            tempPermissions.joined(separator: ","))
    }
    
    /**
     Call when permission allowed.
     Also call if you try request allowed permission.
     
     - parameter permission: Permission which allowed.
     */
    func didAllow(permission: SPPermission) {
        print("Did allow: ", permission.name)
        if(permission.name == "Camera"){
            isCameraDenied = false
        }
        //        PhotoSceneConfigurator.sharedInstance.configure(viewController: self)
        //        //        self.cameraSetup()
        //        if(permission.name == "Photo Library"){
        //            self.photoManagers = PhotoManagersNew.init(frame: self.albumBtn.frame)
        //            self.photoManagers.delegate = self
        //            self.photoManagers.notifyPosterImg()
        //        }
        
    }
    
    /**
     Call when permission denied.
     Also call if you try request denied permission.
     
     - parameter permission: Permission which denied.
     */
    func didDenied(permission: SPPermission) {
        print("Did denied: ", permission.name)
    }
    
    /**
     Alert if permission denied. For disable alert return `nil`.
     If this method not implement, alert will be show with default titles.
     
     - parameter permission: Denied alert data for this permission.
     */
    func deniedData(for permission: SPPermission) -> SPPermissionDeniedAlertData? {
        let data = SPPermissionDeniedAlertData()
        //        data.alertOpenSettingsDeniedPermissionTitle = permission.name + "权限被禁止"
        data.alertOpenSettingsDeniedPermissionTitle =  "相机照片相关权限被禁止"
        data.alertOpenSettingsDeniedPermissionDescription = "为了正常体验请上设置里打开授权"
        data.alertOpenSettingsDeniedPermissionButtonTitle = "设置"
        data.alertOpenSettingsDeniedPermissionCancelTitle = "取消"
        
        return data
        //        if permission == .notification {
        //
        //            return data
        //        } else {
        //            // If returned nil, alert will not show.
        //            print("Alert for \(permission.name) not show, becouse in datasource returned nil for configure data. If you need alert, configure this.")
        //            return nil
        //        }
    }
}

extension MainExController:SlideAnimeShowDelegate{
    func showSlide(isOpen: Bool) {
        
    }
    
    
    
    
}


extension MainExController : CBCentralManagerDelegate,CBPeripheralDelegate,UIScrollViewDelegate {
    //2.检查运行这个App的设备是不是支持BLE。代理方法
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("蓝牙管理中心\(central)")
        switch central.state {
        case .poweredOn:
            print("蓝牙已打开正在描外设\(String(describing: isDeviceCorrect))>>\(DeviceCorrectMac)")
            //            bleStateOn = true
            bleScan()
            connectTime = 0
            
            break
        case .unauthorized:
            print("这个应用程序是无权使用蓝牙低功耗")
            break
        case .poweredOff:
            print("蓝牙已关闭")
            //            bleStateOn = false
            connectTime = 0
            //beforeViewload
            
            cleanConnectionTimer()
            //            if(GlobalToast.isLoading()){
            //                self.manager = CBCentralManager(delegate: self, queue: nil)
            //            }
            defaultCenter.post(name: .Wifi, object: false)
            //            defaultCenter.removeObserver(self, name: .Write, object: nil)
            break
        default:
            print("中央管理器没有改变状态")
        }
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙断开连接")
        defaultCenter.post(name: .Wifi, object: false)
        wifiState = false
        
      
        if(isDeviceCorrect == nil || isDeviceCorrect! == true){
            onSetRenewScan(nil)
        }else{
            self.view.alert()
        }
            
        
    }
    //3.查到外设后，停止扫描，连接设备
    //广播、扫描的响应数据保存在advertisementData 中，可以通过CBAdvertisementData 来访问它
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        
        print("扫描的响应数据:\(peripheral)")
        print("设备广播数据:\(String(describing: advertisementData["kCBAdvDataLocalName"]))")
        
        if(peripheral.name != nil){
            //            print("数据源：\(self.deviceList.count)----\(self.deviceList.index(of: (self.deviceList.count-1)))")
            print("设备名:\(String(describing: peripheral.name))")
            if(!self.deviceList.contains(peripheral)){//peripheral对象包含信号。。。不一样？
                //                self.deviceList.add(peripheral)
                
                if(RSSI.intValue > -90){
                    self.deviceList.insert(peripheral, at: 0)
                    
                }else{
                    self.deviceList.add(peripheral)
                    
                }
                print("初始数据源\(RSSI.intValue)")
                
                /**
                 <CBPeripheral: 0x2804f9220, identifier = E32AF0D0-3F24-7B14-BCD2-0DCA5700775E, name = X06, state = disconnected> 信号===Optional(["RSSI": -61, "advertisementData": {
                 kCBAdvDataIsConnectable = 1;
                 kCBAdvDataManufacturerData = {length = 8, bytes = 0xe7fe05b37105e701};//05B37105e701这个是地址码,05是最低位B3是次低位
                 kCBAdvDataRxPrimaryPHY = 0;
                 kCBAdvDataRxSecondaryPHY = 0;
                 kCBAdvDataServiceUUIDs =     (
                 FEE7
                 );
                 kCBAdvDataTimestamp = "613497512.026559";
                 }])
                 */
                
                nearbyPeripheralInfos[peripheral] = ["RSSI": RSSI, "advertisementData": advertisementData as AnyObject]
                print("搜索到的设备：\(peripheral) 信号===\(String(describing: nearbyPeripheralInfos[peripheral]))")
                
                //                print("广播数据\(nearbyPeripheralInfos[peripheral]!["advertisementData"]!["kCBAdvDataServiceUUIDs"])")
                var saveUUID = Global.getBleUUID()//扫到就连，秒连
                saveUUID = EMPTYVARCHAR
                if(saveUUID != EMPTYVARCHAR){
                    if(peripheral.identifier.description == saveUUID){
                        connect(peripheral)
                        
                        //新版名称
                        
                        //                        if(advertisementData["kCBAdvDataLocalName"] == nil){
                        //                              Global.saveBleName("未知设备", nameKey: NEWNAME)//别名
                        //                        }else{
                        //                            Global.saveBleName(advertisementData["kCBAdvDataLocalName"] as! String, nameKey: NEWNAME)//别名
                        //                        }
                        
                        print("数据源扫到就连，秒连")
                        return
                    }
                }else{
                    //第一次连接、周围只有一个设备的连接
                    //   1.目前蓝牙收到指令后不返回指令
                    //   2.蓝牙是固定设备名
                    //  3.周围设备多优先连接信号强的设备
                    //   4.app之前如果之前有连接绑定过设备优先连接之前绑定的设备
                    //                                  print("广播数据\(nearbyPeripheralInfos[peripheral]!["advertisementData"]!["kCBAdvDataServiceUUIDs"])")
                    //                    (String(describing: self.slideMidY)
                    if let AD = nearbyPeripheralInfos[peripheral]{
                        DeviceCorrectMac = String.init(describing: AD["advertisementData"]!["kCBAdvDataManufacturerData"])
                        
                        print("mac\(DeviceCorrectMac)")
                    }
                    
                    if let _ = nearbyPeripheralInfos[peripheral],((nearbyPeripheralInfos[peripheral]!["advertisementData"]?.description!.contains(BLEServiceSearchUUID))!){
                        connect(peripheral)//先靠UUID判断
                    }else{
                        if let name = peripheral.name{
                            if(name.uppercased().contains("X06")){
                                connect(peripheral)
                            }
                        }
                    }
                    
                    
                    
                }
                //                print("数据源扫到")
                
            }else{
                nearbyPeripheralInfos[peripheral]!["RSSI"] = RSSI
                nearbyPeripheralInfos[peripheral]!["advertisementData"] = advertisementData as AnyObject?
                //                print("数据源信号")
                
            }
        }
    }
    
    //4.连接外设成功，开始发现服务
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral){
        print("连接外设成功===\(peripheral)")
        defaultCenter.post(name: .Wifi, object: true)
        wifiState = true
        //        connectionTime = TimeUtility.currentTimeIntervalDouble()
        cleanConnectionTimer()
        connectingPeripheral = nil
        currentPeripheral = peripheral
        
        self.peripheralTemp = peripheral
        self.peripheralTemp.delegate = self
        self.peripheralTemp.discoverServices(nil)
        //        GlobalToast.hideLoading()//暂停一下？
        connectTime=0
        //        dataItemCount = 0
        
        //新版名称
        
        let name = ((nearbyPeripheralInfos[peripheral]!["advertisementData"]! as! Dictionary) as Dictionary<String, Any>)["kCBAdvDataLocalName"]
        connectionToDo()//停止扫描
        print("数据源新名，秒连\(String(describing: name))")
        
    }
    //连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?){
        print("连接外设失败===\(String(describing: error))")
        defaultCenter.post(name: .Wifi, object: false)
        cleanConnectionTimer()
        //        if(deviceListDialog != nil){
        //
        //        }else{
        bleScan()//重连3次
        //        }
        //        bleScan()//死循环
    }
    
    //5.请求周边去寻找它的服务所列出的特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?){
        if error != nil {
            print("错误的服务特征:\(error!.localizedDescription)")
            return
        }
        for service in peripheral.services! {
            //发现给定格式的服务的特性
            if (service.uuid == kServiceConnectUUID) {
                peripheral.discoverCharacteristics(nil, for: service as CBService)
            }
        }
    }
    //6.已搜索到Characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        if (error != nil){
            print("发现错误的特征：\(error!.localizedDescription)")
            return
        }
        for  characteristic in service.characteristics!  {
            //罗列出所有特性，看哪些是notify方式的，哪些是read方式的，哪些是可写入的。
            print("服务UUID:\(service.uuid)         特征UUID:\(characteristic.uuid)")
            //特征的值被更新，用setNotifyValue:forCharacteristic
            switch characteristic.uuid.description {
            case "\(BLECharacteristicUUID_READ)":
                self.readCharacteristic = characteristic
                //                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.setNotifyValue(true, for: characteristic)
                //                peripheral.readValue(for: characteristic)
                break
            case "\(BLECharacteristicUUID_WRITE)":
                self.writeCharacteristic = characteristic
                if(timerTest == nil){
                    //保活？防止蓝牙超过15秒断开
                    //最开始发送一条密钥之类的指令，确认后不再执行15秒断开
                    //密钥：日期构造？只要是日期的构造与反构造？
                    timerTest = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(testSend), userInfo: nil, repeats: true)
                    
                    if(self.onAction_Confirm == nil && isDeviceCorrect == nil){
                        delayConfirm { (isShakedHand) in
                            isDeviceCorrect = isShakedHand
                            if(!isShakedHand){
                                if(self.peripheralTemp != nil){
                                    //                                    self.peripheralTemp.s
                                    //校验不成功，断开链接
                                    self.manager.cancelPeripheralConnection(self.peripheralTemp)
                                }
                                self.timerTest?.invalidate()
                                self.timerTest = nil
                                print("回调delayConfirm-校验不成功")
                            }
                            self.onAction_Confirm = nil //用完重置

                        }
                    }
                    
                }
                break
            default:
                break
            }
        }
    }
    
    
    //回调确认
    func delayConfirm(returnAct:@escaping onACTION_CONFIRM){
        
        //        tipTxt.text = str
        //
        //        tipTxt.isHidden = false
        print("握手回调delayConfirm-onACTION_CONFIRM")
        self.onAction_Confirm = returnAct
        //延时1秒执行
        let time: TimeInterval = 3.0
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + time) {
            //code
            
            //            self.tipTxt.isHidden = true
            
            //            if(){
            //                startBtnAnimation(3)
            //            }
            if(self.onAction_Confirm != nil){
                self.onAction_Confirm!(false)
                
                print("回调delayConfirm-DispatchQueue--超过2秒,断开")
                
            }
            print("回调delayBtnAnim-DispatchQueue")
        }
        
    }
    
    
    
    //8.获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?){
        if(error != nil){
            print("收到数据错误的特性是：\(characteristic.uuid)     错误信息：\(error!.localizedDescription)       错误数据：\(String(describing: characteristic.value))")
            return
        }
        print("发现服务开始数据：\(peripheral)--特征\(characteristic.uuid.description)")
        
        switch characteristic.uuid.description {
        case "\(BLECharacteristicUUID_READ)":
            print("BLECharacteristicUUID_READ-\(characteristic)")
            if(characteristic.value != nil){
                
                if(((characteristic.value?.isEmpty)!)){
                    
                    //                    Thread.sleep(forTimeInterval: 4)
                    //                    connectTimes = 16
                    //                    connectionToDo()//先通信后动画
                    //                    NotificationCenter.default.post(name: .SetRenewScan , object: nil)
                    //                    bleScan()
                    //                    if(currentPeripheral != nil){
                    //                        self.manager.cancelPeripheralConnection(currentPeripheral!)
                    //                    }
                    
                    
                    
                    
                    print("didUpdateValueFor-none")
                    
                    return
                }
                // macOptional(Optional(<e7fe05b3 7105e701>))
                let s:NSString = BytesToStringUtility.hexadecimalString(characteristic.value) as NSString
                print("回调value配对:\(s)>>\(DeviceCorrectMac)")
                
//                DispatchQueue.main.async {
//                    SVProgressHUD.dismiss(withDelay: 4)
//                    SVProgressHUD.showInfo(withStatus: "蓝牙回传地址数据\(s)>>>本机地址数据\(DeviceCorrectMac)")
//                }
                
                if  s.length > 10{
                    let macReturn = s.substring(with: NSRange.init(location: 6, length: 4))
                    if(isDeviceCorrect == nil){
                        if(DeviceCorrectMac.contains(macReturn)){
                            if(self.onAction_Confirm != nil){
                                self.onAction_Confirm!(true)
                                //设备匹配允许激活
                                defaultCenter.post(name: .ServerActive, object: false)

                                print("回调delayConfirm-校验成功")
                                
                            }
                        }else{
                            if(self.onAction_Confirm != nil){
                               self.onAction_Confirm!(false)
                                print("回调delayConfirm-校验失败")
                              
                             }
                        }
                    }
                    
                }
                
            }
            break
        case "\(BLECharacteristicUUID_WRITE)":
            print("BLECharacteristicUUID_WRITE-\(characteristic)")
            if(characteristic.value != nil && !(characteristic.value?.isEmpty)!){
                //   timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(time), userInfo: nil, repeats: true)
                //开始计时器
                //timer.fire()
                //暂停
                //timer.fireDate = Date.distantFuture
                //继续
                //timer.fireDate = NSDate.init() as Date
                //timer.fireDate = Date.distantPast
                //消除计时器（页面释放是必须调用这个方法，不让会让页面和定时器不会释放）
                //timer.invalidate()
                //滑动timer失效是添加
                //RunLoop.current.add(timer, forMode: .commonModes)
                
            }
            break
        default:
            break
        }
    }
    
    @objc func testSend(){
//                if let dataWrite = BLE_order.sendBeat(){
        if let dataWrite = BLE_order.sendSessionOrder(){
            if(self.peripheralTemp != nil && self.writeCharacteristic != nil ){
                self.peripheralTemp.writeValue(dataWrite, for: self.writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            print("testSend\((BytesToStringUtility.hexadecimalString(dataWrite) as NSString?))")
        }
        
    }
    
    //快
    public func sendMoveFast(_ dir:BLE_order.Direction){
        if let dataWrite = BLE_order.sendFastOrder(dir){
            if(self.peripheralTemp != nil && self.writeCharacteristic != nil ){
                self.peripheralTemp.writeValue(dataWrite, for: self.writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            print("sendMoveFast\((BytesToStringUtility.hexadecimalString(dataWrite) as NSString?))")
        }
    }
    //停
    public func sendMoveHold(){
        if let dataWrite = BLE_order.sendHoldOrder(){
            if(self.peripheralTemp != nil && self.writeCharacteristic != nil ){
                self.peripheralTemp.writeValue(dataWrite, for: self.writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            print("sendMoveHold\((BytesToStringUtility.hexadecimalString(dataWrite) as NSString?))")
        }
    }
    //慢
    public func sendMoveSlow(_ dir:BLE_order.Direction){
        if let dataWrite = BLE_order.sendSlowOrder(dir){
            if(self.peripheralTemp != nil && self.writeCharacteristic != nil ){
                self.peripheralTemp.writeValue(dataWrite, for: self.writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            print("sendMoveSlow\((BytesToStringUtility.hexadecimalString(dataWrite) as NSString?))")
        }
    }
    //慢
    public func sendLEDAction(_ state:BLE_order.LED){
        if let dataWrite = BLE_order.sendLED(state){
            if(self.peripheralTemp != nil && self.writeCharacteristic != nil ){
                self.peripheralTemp.writeValue(dataWrite, for: self.writeCharacteristic, type: CBCharacteristicWriteType.withoutResponse)
            }
            print("sendMoveSlow\((BytesToStringUtility.hexadecimalString(dataWrite) as NSString?))")
        }
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateNotificationStateFor-通知\(peripheral))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("didWriteValueFor-写入成功了\(peripheral))")
    }
    //有来有回？？
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        
        print("readyToSend-释放\(peripheral))")
    }
    //链接成功后停止扫描,正式标记蓝牙连接成功
    func connectionToDo(){
        //保存连接过的
        Global.saveBleUUID(peripheralTemp.identifier.description)
        self.manager.stopScan()
    }
    
    
}

