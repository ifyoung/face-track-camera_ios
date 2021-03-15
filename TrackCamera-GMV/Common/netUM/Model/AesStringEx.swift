//
//  AesStringEx.swift
//  山鹰国际客户
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
         let keysAes = "69530C901192ABE596CD10A288D7D327"
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
//            let aes = try AES(key: "keykeykeykeykeyk", iv: "drowssapdrowssap") // aes128
            
//            let enStr = self.data(using: String.Encoding.utf8)
            // 进行AES加密
//            encryptBytes = try aes.encrypt(Array(self.utf8)).toBase64()!
            var test = "admin_1563882792706_bfaa19b5e4712d28464b4687afeb9196"
            
            var test2 = "eXeKklNxuQX7WJYpBcc9Z3ZNSJMq1rCHjCjhmxCEbGVqa7Ny5xdPUBT5M/7U6IcyWNNYIYBGxMCnEdEryEKxTA=="
            
            var deStr:String = "eXeKklNxuQX7WJYpBcc9Z3OevHvuWVFjwJjraCAXLp/Xh/cd4wT94MMJp3VaMrDFwBbEj3Wv0l+hBqrPcoQW9o19wbSw4B2s1XNet6mNJ2k="
            var deStrAn:String = "TJSSeHiEAu+vB/8hOTM1Oa2HyfkImF0ec0U5864u/i/wQpLlauXfKlV7tfetqk4Sjd0svleWWQt18v2uTb8gZA=="
            // 进行AES加密
//            let enData = try aes.encrypt(Array(self.utf8))
//            let decrypted = try AES(key: Array(keysAes.utf8), blockMode: CBC(iv: iv), padding: .pkcs7).decrypt(enData)
//"{\"type\":\"ios\",\"appid\":\"aaaaaaaaaaaaaaaaaaqqqqqqqqqqqqq\"}"

            let tt2 = try test2.decryptBase64ToString(cipher: aes)
            
            let striEN = try test.encryptToBase64(cipher: aes)
            let ttt = striEN
            let striEN_DE = try deStr.decryptBase64ToString(cipher: aes)
            let striEN_DETT = try striEN! .decryptBase64ToString(cipher: aes)
//            encryptBytes = striEN!
            encryptBytes = try self.encryptToBase64(cipher: aes)!
//            encryptBytes = enData.toBase64()!
            
            
//            let base64ToString = try encryptBytes.decryptBase64ToString(cipher:aes)
//            let base64ToStringStatic = try deStrAn.decryptBase64(cipher:aes)
//            let base64ToStringStaticAA = try deStr.description.fromBase64S()?.data(using: String.Encoding.utf8)?.decrypt(cipher: aes)
//            let base64ToStringAAA = try AES(key: Array(keysAes.utf8), blockMode: CBC(iv: iv), padding: Padding.pkcs7).decrypt(enData)
//            let base64ToStringStraaa = String.init(bytes: base64ToStringStaticAA!.bytes, encoding: String.Encoding.utf8)
//            let base64ToStringStr = String.init(bytes: base64ToStringStatic, encoding: String.Encoding.utf8)
//            print("原始\(self)")
//            print("加密\(encryptBytes)")
//            print("解密\(base64ToString)")
//            print("解密staticData\(base64ToStringStatic)")
//            print("解密String\(base64ToStringStr)")
        } catch {
            // 异常处理
        }
//        let t = encryptBytes

        return encryptBytes
    }
    
    
}
