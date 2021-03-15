//  DGLocalization.swift
// Created by Dip Kasyap on 5/22/15.
// Copyright (c) 2015 Dip Kasyap . All rights reserved.
// DIP: COPYLEFT : Feel Free to Customize & Improve :)


import UIKit

@objc protocol DGLocalizationDelegate {
    @objc optional func languageDidChanged(to:(String))
}

class DGLocalization:NSObject {
    
   weak var Delegate:DGLocalizationDelegate?
    
    //MARK:- Instance var
    var DEFAULTS_KEY_LANGUAGE_CODE = "DEFAULTS_KEY_LANGUAGE_CODE"
    var DEFAULTS_KEY_LANGUAGE_CODE_isChoose = "DEFAULTS_KEY_LANGUAGE_CODE_isChoose"
    var availableLocales = [LocaleDG]() {
        didSet {
            self.setLanguage(withCode: availableLocales.first!)
        }
    }
    
    var currentLocale = LocaleDG()
    
    //MARK:- Int
    override init() {
//        let english = Locale().initWithLanguageCode(languageCode: "en", countryCode: "gb", name: "United Kingdom")
//        zh-Hant
        print("LC当前语言\(NSLocale.preferredLanguages[0] as String)++\(NSLocale.isoCountryCodes)")
        if (NSLocale.preferredLanguages[0] as String).contains("zh-") {
            let Chinese = LocaleDG().initWithLanguageCode(languageCode: "zh-Hans", countryCode: "cn", name: "China")
            self.availableLocales = [Chinese as! LocaleDG]
             print("中文")
        }else if((NSLocale.preferredLanguages[0] as String).contains("ja")){
            let ja = LocaleDG().initWithLanguageCode(languageCode: "ja", countryCode: "jp", name: "Japan")
             self.availableLocales = [ja as! LocaleDG]
             print("日文")
        }else if((NSLocale.preferredLanguages[0] as String).contains("ko")){
            let ko = LocaleDG().initWithLanguageCode(languageCode: "ko", countryCode: "ko", name: "Korean")
             self.availableLocales = [ko as! LocaleDG]
             print("韩文")
        }else if(NSLocale.preferredLanguages[0] as String).contains("es"){//西班牙语es,es-419
            let spanish = LocaleDG().initWithLanguageCode(languageCode: "es", countryCode: "es", name: "Spanish")
            self.availableLocales = [spanish as! LocaleDG]
        }else
//            if(NSLocale.preferredLanguages[0] as String).contains("en")
            {
            let english = LocaleDG().initWithLanguageCode(languageCode: "en", countryCode: "gb", name: "United Kingdom")
            self.availableLocales = [english as! LocaleDG]
                print("其余都默认英文")
        }
        
        
    }
    
    //MARK:- Singleton
    static let sharedInstance: DGLocalization = {DGLocalization()}()
    
    //MARK:- Methods
    func startLocalization(){
        
        let userDefaults = UserDefaults.standard
       let languageManager = DGLocalization.sharedInstance
        
        // Check if the language code has been already been set or not.
        var currentLanguage = userDefaults.string(forKey: DEFAULTS_KEY_LANGUAGE_CODE)
        
        let sysCurrentLanguage = NSLocale.preferredLanguages[0] as String
        _ = ( (NSLocale.current as NSLocale).object(forKey: NSLocale.Key.languageCode) as! NSString)
        
        if(currentLanguage != nil ){
       

            if(!getIsChosen() && !currentLanguage!.contains(sysCurrentLanguage)){
               currentLanguage = nil
            }
            
        }
        if(currentLanguage == nil){
//            let currentLocale:NSLocale = NSLocale.current as NSLocale
            
            // GO through available localisations to find the matching one for the device locale.
            for locale in languageManager.availableLocales {
//                print("languageManager-list\(locale.languageCode)")
//                print("languageManager-listA\(sysCurrentLanguage1)")

                if (locale.languageCode!).contains(String(sysCurrentLanguage.split(separator: "-")[0])){
                    languageManager.setLanguage(withCode: locale)
                    break
                }
            }
            // If the device locale doesn't match any of the available ones, just pick the first one.
            if(((userDefaults.string(forKey: DEFAULTS_KEY_LANGUAGE_CODE))) == nil){
                languageManager.setLanguage(withCode:languageManager.availableLocales[0])
            }
        }
        else {
            languageManager.setLanguage(withCode: LocaleDG().initWithLanguageCode(languageCode: currentLanguage!, countryCode: currentLanguage!, name: currentLanguage!) as! LocaleDG)
        }
    }
    
    func addLanguage(newLang: LocaleDG)  {
        self.availableLocales.append(newLang)
    }
    func getCurrentLanguage()->LocaleDG {
        return currentLocale
    }
    
    func setIsChosen(isChoose:Bool?){
    
        UserDefaults.standard.set(isChoose, forKey:DEFAULTS_KEY_LANGUAGE_CODE_isChoose)

    }
    func getIsChosen()->Bool{
     return UserDefaults.standard.bool(forKey: DEFAULTS_KEY_LANGUAGE_CODE_isChoose)
    }
    
    
    func setLanguage(withCode langCode: AnyObject) {
        let langCode = langCode as! LocaleDG
        UserDefaults.standard.set(langCode.languageCode, forKey:DEFAULTS_KEY_LANGUAGE_CODE)
        //delegate
        if let delegate = Delegate {
            delegate.languageDidChanged!(to: langCode.languageCode! as (String))
        }
        
        self.currentLocale = langCode
    }
    
    // DIP Return a translated string for the given string key.
    func getTranslationForKey(key: String)->String {
        
        // Get the language code.
        let languageCode =  UserDefaults.standard.string(forKey: DEFAULTS_KEY_LANGUAGE_CODE)
        
        // Get language bundle that is relevant.
        let bundlePath = Bundle.main.path(forResource: languageCode as String?, ofType: "lproj")
        let Languagebundle = Bundle(path: bundlePath!)
        
        // Get the translated string using the language bundle.
        let translatedString = Languagebundle?.localizedString(forKey: key as String, value:"", table: nil)
        return translatedString!;
    }
    
    
}


//MARK:- Locale
class LocaleDG: NSObject {
    
    var name:String?
    var languageCode:String?
    var countryCode:String?
    
    func initWithLanguageCode(languageCode: String,countryCode:String,name: String)->AnyObject{
        self.name = name
        self.languageCode = languageCode
        self.countryCode = countryCode
        return self
    }
}


//MARK:- extension
extension String {
    
    func localize()->String{
        return DGLocalization.sharedInstance.getTranslationForKey(key: self)
    }
}
