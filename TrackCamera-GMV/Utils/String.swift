//
//  String.swift
//
//
//  Created by Mohammad Ali Jafarian on 10/6/17.
//

import UIKit
import CommonCrypto

// 下标截取任意位置的便捷方法
extension String {
    
    var length: Int {
        return self.count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)), upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func getTextSize(font:UIFont) -> CGSize{
        
        return (self as NSString).size(withAttributes: [NSAttributedString.Key.font : font])
    }
    
}

extension String {
    
    func bezierPathM(withFont font: UIFont) -> UIBezierPath {
        // create CTFont with UIFont
        let ctFont = CTFontCreateWithName(font.fontName as CFString,
                                          font.pointSize, nil)
        // create a container CGMutablePath for letter paths
        let letters = CGMutablePath()
        // create a NSAttributedString from self
        let attrString = NSAttributedString(string: self,
                                            attributes: [NSAttributedString.Key.font: font])
        // get CTLines from attributed string
        let line = CTLineCreateWithAttributedString(attrString)
        // get CTRuns from line
        let runs = CTLineGetGlyphRuns(line) as! [CTRun]
        for run in runs {
            // number of gylph available
            let  glyphCount = CTRunGetGlyphCount(run)
            for i in 0 ..< glyphCount {
                // take one glyph from run
                let range = CFRangeMake(i, 1)
                // create array to hold glyphs, this should have array with one item
                var glyphs = [CGGlyph](repeating: 0,
                                       count: range.length)
                // create position holder
                var position = CGPoint()
                // get glyph
                CTRunGetGlyphs(run,
                               range,
                               &glyphs)
                // glyph postion
                CTRunGetPositions(run,
                                  range,
                                  &position)
                // append glyph path to letters
                for glyph in glyphs {
                    if let letter = CTFontCreatePathForGlyph(ctFont,
                                                             glyph, nil) {
                        letters.addPath(letter,
                                        transform: CGAffineTransform(translationX: position.x,
                                                                     y: position.y))
                    }
                }
                
            }
        }
        // following lines normalize path. this path is created with textMatrix so it should first be normalized to nomral matrix
        let lettersRotated = CGMutablePath()
        lettersRotated.addPath(letters,
                               transform: CGAffineTransform(scaleX: 1,
                                                            y: -1))
        let lettersMoved = CGMutablePath()
        lettersMoved.addPath(lettersRotated,
                             transform: CGAffineTransform(translationX: 0,
                                                          y: lettersRotated
                                                            .boundingBoxOfPath
                                                            .size
                                                            .height))
        // create UIBezierPath
        let bezier = UIBezierPath(cgPath: lettersMoved)
        return bezier
    }
    
    //手柄版本格式构造
    //a-f
    func getHandleVer(s:String) -> String {
        var ver = s
        if(ver.count<3){
            return "N/A"
        }
        ver.insert(".", at: ver.index(ver.startIndex, offsetBy: 1))
        ver.insert("/", at: ver.index(ver.startIndex, offsetBy: 3))
        ver.insert(".", at: ver.index(ver.startIndex, offsetBy: 5))
        
        let bigV = "abcdef"
        var temp = ""
        
        for l in bigV{
            if(ver.contains(l)){
                temp =  ver.replacingOccurrences(of:l.description, with: String.init(10 + (bigV.firstIndex(of: l)?.encodedOffset)!))
                //                utf16Offset
            }
        }
        if(!temp.isEmpty){
            ver = temp
        }
        
        return ver
    }
    
    func versionCompareUP(strLoc:String,strSer:String)->Bool{
        //有新版本
        if(strSer.compare(strLoc) == ComparisonResult.orderedDescending) {
            
            return true
        }
        
        return false
    }
    
    // 判断输入的字符串是否为数字，不含其它字符
    
    func isPurnInt() -> Bool {
        
        let scan: Scanner = Scanner(string: self)
        
        var val:Int = 0
        
        return scan.scanInt(&val) && scan.isAtEnd
        
    }
    
    
    ///认证码生成
    func generateVerifyCode(length: Int)->String{
        let charactersALL = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        /**
         生成随机字符串,
         - parameter length: 生成的字符串的长度
         - returns: 随机生成的字符串
         */
        var ranStr = ""
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(charactersALL.count)))
            //              ranStr.append(characters[characters.startIndex.advancedBy(index)])
            ranStr.append(charactersALL[charactersALL.index(charactersALL.startIndex, offsetBy: index)])
        }
        return ranStr
        
        
    }
    //    MD5
    func md5() -> String {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CUnsignedInt(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(str!, strLen, result)
        let hash = NSMutableString()
        for i in 0 ..< digestLen {
            hash.appendFormat("%02x", result[i])
        }
        free(result)
        return String(format: hash as String)
    }
    //    public static String genToken(String tokenPrim) {
    //    StringBuffer signStr = new StringBuffer();
    //    signStr.append(tokenPrim.replaceAll("_", "\\$")).append("_");
    //    signStr.append(new Date().getTime()).append("_");
    //    String keyStr = signStr.toString() + "0EC28E604767C487AE293F5A7854522F";
    //    //        String sign= DigestUtils.md5Hex(keyStr);
    //    String sign = MyTextUtil.md5(keyStr);
    //    signStr.append(sign);
    //
    //    String test = "admin_1563882792706_bfaa19b5e4712d28464b4687afeb9196";
    //
    //    //String base64Key = KeyPairGenUtilAn.encryption(signStr.toString());
    //    //        String base64Key = KeyPairGenUtil.encryption(signStr.append(sign).toString());
    //    //        String base64Key = KeyPairGenUtil.encryption(test);
    //    //        String jiemi1 = KeyPairGenUtil.deciphering(base64Key);
    //    //        String jiemi = KeyPairGenUtil.deciphering("pZmuX+XA/JGUNdax39XVWGRrbyoKXVoSzGKLbE5VaqhojOdeyIY/6EEtyYz5Er95nMjk0qZaH3rG4ZWZifoOYYXVfmyQCxEBwZyQzWohBkf9vUpvzgaqi5owz9aTJO6hIsSb30kvfHtwYyxIkJngGsmzgBkeCVzYivGIzCnfXS0=");
    //    return signStr.toString();
    //    }
    
    func genToken()-> String {
        var signStr = ""
        
        signStr.append(self.replacingOccurrences(of: "_", with: "\\$"))
        signStr.append("_")
//        android time 1563970807247
//                     1563971106583
        let t = Date().timeIntervalSince1970
        let millisecond = CLongLong(round(t*1000))

        print("time\(Date().timeIntervalSince1970)" )
        signStr.append(millisecond.description)
        signStr.append("_")
        
        let keyStr = signStr + "0EC28E604767C487AE293F5A7854522F"
        
        let sign = keyStr.md5()
        signStr.append(sign)
        
        
        return signStr
    }
    
    
    
    
    
}
