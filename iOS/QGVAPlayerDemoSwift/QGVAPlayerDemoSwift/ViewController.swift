// ViewController.swift
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 Tencent.  All rights reserved.
//
// Licensed under the MIT License (the "License"); you may not use this file except in
// compliance with the License. You may obtain a copy of the License at
//
// http://opensource.org/licenses/MIT
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
// either express or implied. See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import QGVAPlayer

class ViewController: UIViewController, VAPWrapViewDelegate {
    var vapView = QGVAPWrapView.init()
    let vapButton = UIButton()
    var customFont: UIFont?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vapButton.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 90)
        vapButton.backgroundColor = UIColor.lightGray
        vapButton.setTitle("融合动效（更多示例请查看OC版本）", for: UIControl.State.normal)
        vapButton.addTarget(self, action: #selector(playVapx), for: UIControl.Event.touchUpInside)
        self.view.addSubview(vapButton)
        self.view.addSubview(vapView)
        QGVAPTextureLoader.loadCustomFont(nil)
        QGVAPTextureLoader.loadCustomFont { fontSize, isBold in
            return UIFont.systemFont(ofSize: 12)
        }
    }
    
    @objc func playVapx() {
        
        let mp4Path = String.init(format: "%@/Resource/vap.mp4", Bundle.main.resourcePath!)
        vapView.center = self.view.center
        vapView.isUserInteractionEnabled = true
        vapView.contentMode = .top
        vapView.hwd_enterBackgroundOP = HWDMP4EBOperationType.stop
        //        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(onTap(gesture:)))
        //        vapView.addGestureRecognizer(gesture)
        vapView.playHWDMP4(mp4Path, repeatCount: 0, delegate: self)
        
        
        //        test.ttf
        //    // 使用示例：从文档目录加载
            if let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fontPath = docPath.appendingPathComponent("test.ttf").path
                if let font = loadFontFromFile(path: fontPath, size: 16) {
                    self.customFont = font
                }
            }
    }
    
    func loadFontFromFile(path: String, size: CGFloat) -> UIFont? {
        guard let fontURL = URL(fileURLWithPath: path) as CFURL?,
              let dataProvider = CGDataProvider(url: fontURL),
              let cgFont = CGFont(dataProvider) else {
            return nil
        }
        let fontName = cgFont.postScriptName! as String
        if self.isFontRegistered(fontName: fontName) {
            return UIFont(name: fontName, size: size)
        }
        
        var error: Unmanaged<CFError>?
        // 注册字体到系统
        if CTFontManagerRegisterGraphicsFont(cgFont, &error) {
            
            return UIFont(name: fontName, size: size)
        } else {
            print("字体注册失败：\(error?.takeUnretainedValue() ?? NSError() as! CFError)")
            return nil
        }
    }
    
    /// 检查字体是否已注册
    func isFontRegistered(fontName: String) -> Bool {
        // 遍历所有字体家族
        for family in UIFont.familyNames {
            // 获取家族下的所有字体名称
            for name in UIFont.fontNames(forFamilyName: family) {
                if name == fontName {
                    return true
                }
            }
        }
        return false
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        vapView.frame = self.view.bounds
    }
    @objc func onTap(gesture: UIGestureRecognizer) {
        gesture.view?.stopHWDMP4()
        gesture.view?.removeFromSuperview()
    }
    

    
    func vapWrapview_content(forVapTag tag: String, resource info: QGVAPSourceInfo) -> String {
        let extraInfo: [String:String] = ["[sImg1]" : "http://shp.qlogo.cn/pghead/Q3auHgzwzM6GuU0Y6q6sKHzq3MjY1aGibIzR4xrJc1VY/60",
                                          "[textAnchor]" : "afdas123123123",
                                          "[textUser]" : "afdaf12312312",]
        
        return extraInfo[tag] ?? ""
    }

    func vapWrapView_loadVapImage(withURL urlStr: String, context: [AnyHashable : Any], completion completionBlock: @escaping VAPImageCompletionBlock) {
        DispatchQueue.main.async {
            let image = UIImage.init(named: String.init(format:"%@/Resource/qq.png", Bundle.main.resourcePath!))
            completionBlock(image, nil, urlStr)
        }
    }
    
    func vapWrapView_loadVapContent(_ content: String, context: [AnyHashable : Any]) -> UIImage? {
        let resoure = context["resource"] as? QGVAPSourceInfo;
        let color = resoure?.color ?? UIColor.white
        let size = resoure?.size ?? CGSize.zero
        let isBlod = resoure?.style == QGAGAttachmentSourceStyle.boldText;
        QGVAPTextureLoader.drawingCustomImage(forText: content, color: color, size: size, bold: isBlod) { fontSize, isBlod in
             
            if let docPath = Bundle.main.path(forResource: "test.ttf", ofType: nil) {
                if let font = self.loadFontFromFile(path: docPath, size: fontSize) {
                    return font
                }
            }
            if isBlod {
                return UIFont.boldSystemFont(ofSize: fontSize)
            }
            return UIFont.systemFont(ofSize: fontSize)
        }
        return nil
    }
    
}

