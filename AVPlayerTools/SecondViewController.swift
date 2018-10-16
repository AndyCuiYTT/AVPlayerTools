//
//  SecondViewController.swift
//  AVPlayerTools
//
//  Created by qiuweniOS on 2018/9/30.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let playerview = YTTPlayerView(frame: CGRect(x: 10, y:  100, width: UIScreen.main.bounds.width - 20, height: 200))
        self.view.addSubview(playerview)
        if let path = Bundle.main.path(forResource: "qnyn_juqing", ofType: "mp4") {
            playerview.exchangePlayerItem(title: "测试", url: URL(fileURLWithPath: path))
        }
        
        let pview = YTTPlayerView(frame: CGRect(x: 10, y: 400, width: UIScreen.main.bounds.width - 20, height: 200))
        pview.backgroundColor = UIColor.red
        self.view.addSubview(pview)
    }
    


}
