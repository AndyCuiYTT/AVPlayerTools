//
//  ViewController.swift
//  AVPlyerTools
//
//  Created by qiuweniOS on 2018/6/13.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    /*
     
     http://up.mcyt.net/?down/47734.mp3
     
     http://up.mcyt.net/?down/32474.mp3
     
     http://up.mcyt.net/?down/32476.mp3
     */
    @IBOutlet weak var sliderView: UISlider!
    
    let tools = YTTPlayerTools()
    let data = [YTTMediaInfo(url: "http://up.mcyt.net/?down/32476.mp3", title: "执着", singer: "黄勇", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32474.mp3", title: "再见青春", singer: "许哲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32473.mp3", title: "存在", singer: "贝贝", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32472.mp3", title: "恒星", singer: "张鑫鑫", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32471.mp3", title: "鱼", singer: "黄霄雲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32469.mp3", title: "我的天空", singer: "贝贝 / 修儿", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32476.mp3", title: "执着", singer: "黄勇", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32474.mp3", title: "再见青春", singer: "许哲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32473.mp3", title: "存在", singer: "贝贝", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32472.mp3", title: "恒星", singer: "张鑫鑫", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32471.mp3", title: "鱼", singer: "黄霄雲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32469.mp3", title: "我的天空", singer: "贝贝 / 修儿", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32476.mp3", title: "执着", singer: "黄勇", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32474.mp3", title: "再见青春", singer: "许哲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32473.mp3", title: "存在", singer: "贝贝", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32472.mp3", title: "恒星", singer: "张鑫鑫", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32471.mp3", title: "鱼", singer: "黄霄雲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32469.mp3", title: "我的天空", singer: "贝贝 / 修儿", image: UIImage(named: "tmp") )
        
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tools.delegate = self
        tools.exchagePlayItem(atIndex: 0)
    }

    @IBAction func next(_ sender: UIButton) {
        tools.next()
    }
    
    @IBAction func pre(_ sender: UIButton) {
       
        tools.previous()
    }
    
    @IBAction func pause(_ sender: UIButton) {
        if sender.isSelected {
            tools.play()
        }else {
            tools.pause()
        }
        sender.isSelected = !sender.isSelected
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

  

}

extension ViewController: YTTPlayerProtocol {
    
    func player(_ player: YTTPlayerTools, loadFailedAt index: Int) {
        player.next()
    }
    
    func numberOfMedia(_ player: YTTPlayerTools) -> Int {
        return data.count
    }
    
    func player(_ player: YTTPlayerTools, playAt index: Int) -> YTTMediaInfo {
        return data[index]
    }
    
    func player(_ player: YTTPlayerTools, currentTime: TimeInterval, totalTime: TimeInterval) {
        sliderView.value = Float(currentTime / totalTime)
    }
    
    func player(_ player: YTTPlayerTools, cacheTime: TimeInterval, totalTime: TimeInterval) {
        
    }
    
    func playerStartPlay(_ player: YTTPlayerTools) {
        
    }
    
   
    
    
}

