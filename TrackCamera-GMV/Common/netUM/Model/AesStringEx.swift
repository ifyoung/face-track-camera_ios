//
//  AesStringEx.swift

//
//  Created by LCh on 2019/7/27.
//  Copyright © 2019 LCh. All rights reserved.
//

import Foundation
import CryptoSwift


extension String {

    
    // base64编码
    func toBase64S() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    // base64解码
    func fromBase64S() -> String? {
        if let data = Data(base64Encoded: self) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    
    
    //    填充方式:
    //    - parameters:
    //    - noPadding
    //    - zeroPadding
    //    - pkcs7
    //    - pkcs5
    //    加密模式:
    //    - CBC
    //    — CTR
    //    - OFB
    //    - CFB
    //    - ECB
    //
    //    作者：ZealPenK
    //    链接：https://www.jianshu.com/p/ece314c0befd
    //    来源：简书
    //    简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
    
    func AesEncrypt()->String{
         let keysAes = "2132321321313213131"
        var encryptBytes = self
//        Array("0123456789012345".utf8)
//        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)
//        let iv: Array<UInt8> = Array("1234567812345678".utf8)
        let iv: Array<UInt8> = AES.randomIV(AES.blockSize)

        // do-catch进行异常抛出
        do {
            // 出初始化AES
//            let aes = try AES(key: Array(keysAes.utf8), blockMode: CBC(iv: iv), padding: .pkcs7)
//            let aes = try AES(key: Array(keysAes.utf8), blockMode:CBC(iv:iv), padding: .pkcs7)
            
            
            let aes = try AES.init(key: Array(keysAes.utf8), blockMode: ECB(), padding: Padding.pkcs7)

//            let striEN_DETT = try striEN! .decryptBase64ToString(cipher: aes)
//            encryptBytes = striEN!
            encryptBytes = try self.encryptToBase64(cipher: aes)!
//            encryptBytes = enData.toBase64()!
            
            
        } catch {
            // 异常处理
        }
//        let t = encryptBytes

        return encryptBytes
    }
    
    
}
