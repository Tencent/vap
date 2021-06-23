// ViewController.swift
// Tencent is pleased to support the open source community by making vap available.
//
// Copyright (C) 2020 THL A29 Limited, a Tencent company.  All rights reserved.
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

class ViewController: UIViewController, HWDMP4PlayDelegate {
    
    let vapButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vapButton.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: 90)
        vapButton.backgroundColor = UIColor.lightGray
        vapButton.setTitle("融合动效（更多示例请查看OC版本）", for: UIControl.State.normal)
        vapButton.addTarget(self, action: #selector(playVapx), for: UIControl.Event.touchUpInside)
        self.view.addSubview(vapButton)
    }
    
    @objc func playVapx() {
        let vapView = UIView.init(frame: self.view.bounds)
        let mp4Path = String.init(format: "%@/Resource/vap.mp4", Bundle.main.resourcePath!)
        self.view.addSubview(vapView)
        vapView.center = self.view.center
        vapView.isUserInteractionEnabled = true
        vapView.hwd_enterBackgroundOP = HWDMP4EBOperationType.stop
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(onTap(gesture:)))
        vapView.addGestureRecognizer(gesture)
        vapView.playHWDMP4(mp4Path, repeatCount: -1, delegate: self)
        
    }
    
    @objc func onTap(gesture: UIGestureRecognizer) {
        gesture.view?.stopHWDMP4()
        gesture.view?.removeFromSuperview()
    }
    
    func content(forVapTag tag: String!, resource info: QGVAPSourceInfo) -> String {
        let extraInfo: [String:String] = ["[sImg1]" : "http://shp.qlogo.cn/pghead/Q3auHgzwzM6GuU0Y6q6sKHzq3MjY1aGibIzR4xrJc1VY/60",
                                          "[textAnchor]" : "我是主播名",
                                          "[textUser]" : "我是用户名😂😂",]
        
        return extraInfo[tag] ?? ""
    }
    
    func loadVapImage(withURL urlStr: String!, context: [AnyHashable : Any]!, completion completionBlock: VAPImageCompletionBlock!) {
        DispatchQueue.main.async {
            let image = UIImage.init(named: String.init(format:"%@/Resource/qq.png", Bundle.main.resourcePath!))
            completionBlock(image, nil, urlStr)
        }
    }


}

