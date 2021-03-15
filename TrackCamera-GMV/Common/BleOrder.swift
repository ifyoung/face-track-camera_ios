
//
//let BLEServiceUUID = "0000FFB0-0000-1000-8000-00805F9B34FB"
//let BLECharacteristicUUID_WRITE  = "0000FFB1-0000-1000-8000-00805F9B34FB"
//let BLECharacteristicUUID_READ  = "00000FFB2-0000-1000-8000-00805F9B34FB"
@objc enum BLE_order:UInt8{
    case Header_1 = 0xfe //byte1
    case Header_2 = 0x5a //byte2
    case DataLength = 0x03 //byte3
    @objc enum Direction:UInt8{ //byte4
        case Hold_Left = 0x00//没移动,左
        //    case Move_Left = 0x00//左
        case Right = 0x01
    }
    enum Speed:UInt8{ //byte4
        case None = 0x00//没移动,左
        //    case Move_Left = 0x00//左
        case Slow = 0x01
        case Fast = 0x02
    }
    
    enum LED:UInt8 {
        case Shoot = 0xc5
        case RecordStart = 0x55
        case RecordStop = 0xd5
    }
    
    //最后一个校验码
    //Checksum=byte3+byte4+byte5 取低8位有效
    
    //返回指令：fe5a03+mac_addr0+mac_addr1 + end(3+4+5)
    static func sendSessionOrder()->Data?{
        //        var order = [UInt8]()
        
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        //        let body = [Direction.Hold_Left.rawValue,Speed.None.rawValue]
        let body = [Header_2.rawValue,Speed.None.rawValue]//握手码
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body + end
        return orderWrap(order)
        
    }
    
    static func sendHoldOrder()->Data?{
        //        var order = [UInt8]()
        
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        let body = [Direction.Hold_Left.rawValue,Speed.None.rawValue]
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body + end
        return orderWrap(order)
        
    }
    
    
    
    static func sendBeat()->Data?{//保持连接
        //        var order = [UInt8]()
        
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        let body = [Direction.Hold_Left.rawValue,Speed.None.rawValue]
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body
        return orderWrap(order)
        
    }
    
    static func sendFastOrder(_ dir:Direction) -> Data?{
        //        var order = [UInt8]()
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        let body = [dir.rawValue,Speed.Fast.rawValue]
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body + end
        return  orderWrap(order)
        //            return
    }
    
    static func sendSlowOrder(_ dir:Direction) -> Data?{
        //        var order = [UInt8]()
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        let body = [ dir.rawValue,Speed.Slow.rawValue]
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body + end
        return  orderWrap(order)
        //            return
    }
    //led动作
    static func sendLED(_ state:LED) -> Data?{
        //        var order = [UInt8]()
        //        order.append(BLE_order.Header_1)
        let header = [Header_1.rawValue,Header_2.rawValue]
        let length = [0x03] as [UInt8]
        let body = [state.rawValue,Speed.None.rawValue]
        let end = [length[0] + body[0] + body[1]]
        let order = header + length + body + end
        return  orderWrap(order)
        //            return
    }
    
    //    static func sendRightFastOrder() -> Data?{
    //        //        var order = [UInt8]()
    //        //        order.append(BLE_order.Header_1)
    //        let header = [Header_1.rawValue,Header_2.rawValue]
    //        let length = [0x03] as [UInt8]
    //        let body = [Direction.Right.rawValue,Speed.Fast.rawValue]
    //        let end = [length[0] + body[0] + body[1]]
    //        let order = header + length + body + end
    //      return  orderWrap(order)
    //        //            return
    //    }
    
    
    
}
let BLEServiceSearchUUID = "FEE7"
let BLEServiceConnectUUID = "FFB0"
let BLECharacteristicUUID_WRITE  = "FFB1"//写
let BLECharacteristicUUID_READ  = "FFB2"//读取


var deviceOrientation = TgDirection.directionUnkown

enum APP_ver{
    case Release
    case Test
    case Simulator
}

enum FaceEngine{
    case ARC
    case APPLE
}

let APP = APP_ver.Release
let APP_faceEngine = FaceEngine.ARC

//设备是否合法,校验前状态为nil
var isDeviceCorrect:Bool? = nil
var wifiState:Bool = false{
    didSet{
        if(wifiState == false){
            isDeviceCorrect = nil
        }
    }
}

func orderWrap(_ order:[UInt8])->Data?{
    if(wifiState || APP == .Test){
        //        let byteSN:[UInt8] = [P_50,0x06,0x33,0x7f,0x32,P_41]
        var tempOrder = order
        //第二位指令长度
        //        tempOrder[1] = UInt8(order.count)
        //        let t = tempOrder
        let orderData = Data(bytes: UnsafePointer<UInt8>(tempOrder), count: tempOrder.count)
        
        
        //        NotificationCenter.default.post(name: NSNotification.Name("Write"), object: orderData)
        return orderData
    }
    return nil
}
