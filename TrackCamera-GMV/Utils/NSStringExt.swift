
import UIKit
import Foundation

extension NSString {
   

    func stringHeightWith(_ fontSize:CGFloat,width:CGFloat)->CGFloat

    {
        let font = UIFont.systemFont(ofSize: fontSize)
        return self.stringHeightWiths(font, width: width)
    }
    
    func stringHeightWiths(_ font:UIFont,width:CGFloat)->CGFloat{
        let size = CGSize(width: width,height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let  attributes = [NSAttributedString.Key.font:font,
                           NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
    func dateStringFromTimestamp(_ timeStamp:NSString)->String
    {
        let ts = timeStamp.doubleValue
        let  formatter = DateFormatter ()
        formatter.dateFormat = "yyyy年MM月dd日 HH:MM:ss"
        let date = Date(timeIntervalSince1970 : ts)
         return  formatter.string(from: date)
        
    }
    
    func stringWidthWith(_ fontSize:CGFloat)->CGFloat{
        let text=self as NSString
        let size: CGSize=text.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        return ceil(size.width)
    }
    
    func stringWidthWithFont(_ font:UIFont)->CGFloat{
        let text=self as NSString
        let size: CGSize=text.size(withAttributes: [NSAttributedString.Key.font: font])
        return ceil(size.width)
    }
    
    func string16ToInt() -> Int {
        let str = self.uppercased
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
}
