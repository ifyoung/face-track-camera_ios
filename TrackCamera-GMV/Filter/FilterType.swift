//
//  FilterType.swift
//  BBMetalImageDemo
//
//  Created by Kaibo Lu on 4/10/19.
//  Copyright © 2019 Kaibo Lu. All rights reserved.
//
import Metal


//enum Device {
//    case iPad, iPhone, AppleTV, AppleWatch
//    func introduced() -> String {
//       switch self {
//         case AppleTV: return "\(self) was introduced 2006"
//         case iPhone: return "\(self) was introduced 2007"
//         case iPad: return "\(self) was introduced 2010"
//         case AppleWatch: return "\(self) was introduced 2014"
//       }
//    }
//}




enum FilterType {
    
    case lookup//复古
    case colorInversion//底片
    case monochrome//黑白-灰
    case luminance//黑白-正常
    case luminanceThreshold//黑白极度
    case erosion//复古黑白
    case chromaKey//反转指定颜色，这儿是蓝色
    
    case tiltShift//微距？？，聚焦部分，模糊周边
    
    case hueBlend//淡融合
    
    case pixellate//像素
    case polarPixellate//射状像素
    case polkaDot//波尔卡点
    case halftone//半色调
    case swirl//漩涡
    case stretch//哈哈镜，变形
    case emboss//压花
    case sobelEdgeDetection//轮廓
    case bilateralBlur//美白磨皮-强
    case beauty//美白磨皮-弱
    case none//无
    
    func name() -> String {
        return "\(self)"
    }
    func name_zh() -> String {
        switch self {
            
            
            
        case .lookup:
            return "str_filter_lookup".localize()
            
        case .colorInversion:
            return "str_filter_colorInversion".localize()
            
        case .luminance:
            return "str_filter_luminance".localize()
            
        case .erosion:
            return "str_filter_erosion".localize()
            
            //        case .gaussianBlur:
            //            return "高斯"
            
            
        case .polarPixellate:
            return "str_filter_polarPixellate".localize()
        case .polkaDot:
            return "str_filter_polkaDot".localize()
        case .stretch:
            return "str_filter_stretch".localize()
        case .swirl:
            return "str_filter_swirl".localize()
        case .emboss:
            return "str_filter_emboss".localize()
        case .sobelEdgeDetection:
            return "str_filter_edge".localize()
        case .bilateralBlur:
            return "str_filter_bilateralBlur".localize()
        case .beauty:
            return "str_filter_beauty".localize()
        case .none:
            return "str_filter_none".localize()
            
        default:
            return "\(self)"
            
        }
        
        
        //        return "\(self)"
    }
    
}
//FilterType.none例外，没有name
let defaultFilters = [//隐藏没有翻译的
    FilterType.bilateralBlur,
//    FilterType.beauty,
    FilterType.lookup,
    //    FilterType.tiltShift,
    //    FilterType.chromaKey,
    //    FilterType.hueBlend,
    //    FilterType.pixellate,
    FilterType.polarPixellate,
    FilterType.polkaDot,
    //    FilterType.halftone,
    //    FilterType.gaussianBlur,
    FilterType.swirl,
    FilterType.stretch,
    //                      FilterType.emboss,
    FilterType.sobelEdgeDetection,
    FilterType.colorInversion,
    FilterType.luminance,
    FilterType.erosion]

class FilterManager{
    //    private var imageSource: BBMetalStaticImageSource?
    //    private var filterResultList = [BBMetalBaseFilter?]()
    public var filterTypeList = [FilterType](){
        didSet {
            if(filterTypeList != oldValue){
                
            }
        }
    }
    
    static let sharedInstance: FilterManager = {
        let instance = FilterManager()
        // setup code
        return instance
    }()
    
    public func getFilterList(filters:[FilterType]? = nil)->[BBMetalBaseFilter?]{
        var filtersInner = defaultFilters
        var filterResultList = [BBMetalBaseFilter?]()
        if(filters != nil){
            filtersInner = filters!
        }
        for item in filtersInner {
            if let filter = getFilterByType(type: item){
                //                filterResultList.contains { (item) -> Bool in
                //                    if(item.name == filter.name){
                //
                //                    }
                //                }
                print("filtersInner--\(filter.name)")
                let includeItems = filterResultList.filter {
                    return $0!.name == filter.name
                }
                if(includeItems.count == 0){//没有才添加
                    filterResultList.append(filter)
                }
            }
        }
        filterResultList.insert(nil, at: 0)//第一个默认无滤镜
        return filterResultList
    }
    
    public func getFilterByName(name:String)->BBMetalBaseFilter?{
        var tempTy = FilterType.none
        defaultFilters.forEach { (ty) in
            if(name.lowercased().contains(ty.name().lowercased())){
                tempTy = ty
            }
        }
        return getFilterByType(type: tempTy)
    }
    
    
    private func getFilterByType(type:FilterType)->BBMetalBaseFilter?{
        
        switch type {
            
        case .lookup:
            //访问不到assets
            //            let url = Bundle.main.url(forResource: "test_lookup", withExtension: "png")!
            //            let data = try! Data(contentsOf: url)
            
            //            guard let asset = NSDataAsset(name: "test_lookup") else {
            //                fatalError("Missing data asset: NamedColors")
            //            }
            let lookUp = UIImage.init(named:"test_lookup")
            //            var data = lookUp!.jpegData(compressionQuality: 1.0)
            let data = lookUp!.pngData()
            
            return BBMetalLookupFilter(lookupTable: data!.bb_metalTexture!, intensity: 1)
        case .colorInversion: return BBMetalColorInversionFilter()
        case .monochrome: return BBMetalMonochromeFilter(color: BBMetalColor(red: 0.7, green: 0.6, blue: 0.5), intensity: 1)
            
        case .luminance: return BBMetalLuminanceFilter()
        case .luminanceThreshold: return BBMetalLuminanceThresholdFilter(threshold: 0.6)
        case .erosion: return BBMetalErosionFilter(pixelRadius: 2)
            
        case .chromaKey: return BBMetalChromaKeyFilter(thresholdSensitivity: 0.4, smoothing: 0.1, colorToReplace: .blue)
            
        case .tiltShift: return BBMetalTiltShiftFilter()
            
        case .hueBlend:
            //            imageSource = BBMetalStaticImageSource(image: topBlendImage(withAlpha: 1))
            return BBMetalHueBlendFilter()
            
        case .pixellate: return BBMetalPixellateFilter(fractionalWidth: 0.05)
        case .polarPixellate: return BBMetalPolarPixellateFilter(pixelSize: BBMetalSize(width: 0.05, height: 0.03), center: BBMetalPosition(x: 0.35, y: 0.55))
        case .polkaDot: return BBMetalPolkaDotFilter(fractionalWidth: 0.05, dotScaling: 0.9)
        case .halftone: return BBMetalHalftoneFilter(fractionalWidth: 0.01)
//BBMetalPosition(x: 0.35, y: 0.55)
//         case .stretch: return BBMetalStretchFilter()
        case .stretch: return BBMetalStretchFilter(center: BBMetalPosition(x: 0.5, y: 0.7))
            
        case .swirl: return BBMetalSwirlFilter()
        case .emboss: return BBMetalEmbossFilter(intensity: 1)
        case .sobelEdgeDetection: return BBMetalSobelEdgeDetectionFilter()
        case .bilateralBlur: return BBMetalBilateralBlurFilter()
        case .beauty: return BBMetalBeautyFilter()
        case .none:
            return nil
        }
    }
    
    //    private func topBlendImage(withAlpha alpha: Float) -> UIImage {
    //        let image = UIImage(named: "multicolour_flowers.jpg")!
    //        if alpha == 1 { return image }
    //        return BBMetalRGBAFilter(alpha: alpha).filteredImage(with: image)!
    //    }
    
}


