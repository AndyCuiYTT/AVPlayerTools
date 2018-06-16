//
//  ViewController.swift
//  AVPlyerTools
//
//  Created by AndyCui on 2018/6/13.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    /*
     
     http://up.mcyt.net/?down/47734.mp3
     
     http://up.mcyt.net/?down/32474.mp3
     
     http://up.mcyt.net/?down/32476.mp3
     */
    @IBOutlet weak var sliderView: UISlider!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var singerLabel: UILabel!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    
    
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    
    let tools = YTTPlayerTools()
    let data = [YTTMediaInfo(url: "http://up.mcyt.net/?down/32474.mp3", title: "再见青春", singer: "许哲", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32473.mp3", title: "存在", singer: "贝贝", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/32472.mp3", title: "恒星", singer: "张鑫鑫", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47744.mp3", title: "一万个理由", singer: "郑源", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47740.mp3", title: "洋葱", singer: "五月天", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47746.mp3", title: "为什么相爱的人不能在一起", singer: "郑源", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47745.mp3", title: "我不后悔", singer: "郑源", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47754.mp3", title: "飞行时刻", singer: "韩红", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47747.mp3", title: "偏爱", singer: "张芸京", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47752.mp3", title: "A Little Love", singer: "冯曦妤", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47734.mp3", title: "哑巴", singer: "薛之谦", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/46879.mp3", title: "等一分钟", singer: "Dj晓杰&彭芳", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47715.mp3", title: "Take Me Home Country Road", singer: "John Denver", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47751.mp3", title: "遥不可及的你", singer: "花粥", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47748.mp3", title: "春泥", singer: "庾澄庆", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47753.mp3", title: "faded", singer: "mathias fritsche", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47757.mp3", title: "走着走着就散了", singer: "庄心妍", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47756.mp3", title: "温柔与霸道", singer: "杭娇", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47780.mp3", title: "谁能比我更爱你", singer: "崔忠华", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47706.mp3", title: "我是真的为你哭了", singer: "韩信", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47702.mp3", title: "姑娘我爱上你", singer: "DJ小鱼儿&天孪兄弟", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47699.mp3", title: "太多", singer: "Dj伟伟&孙露", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47741.mp3", title: "你的样子", singer: "雨宗林&杨蔓", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/44566.mp3", title: "不做你幸福的玫瑰", singer: "--", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47781.mp3", title: "天籁之爱", singer: "阿鲁阿卓&泽旺多吉", image: UIImage(named: "tmp") ),
                YTTMediaInfo(url: "http://up.mcyt.net/?down/47750.mp3", title: "我也有个中国梦", singer: "陈思霓", image: UIImage(named: "tmp") ),
            



               
                
        
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
    
   
    func player(_ player: YTTPlayerTools, playFailedAt index: Int) {
        player.next()
    }
    
    func player(_ player: YTTPlayerTools, playToEndTimeAt index: Int) {
        player.next()
    }
    
    func numberOfMedia(_ player: YTTPlayerTools) -> Int {
        return data.count
    }
    
    func player(_ player: YTTPlayerTools, playAt index: Int) -> YTTMediaInfo {
        print(index)
        return data[index]
    }
    
    func player(_ player: YTTPlayerTools, currentTime: TimeInterval, totalTime: TimeInterval) {
        sliderView.value = Float(currentTime / totalTime)
        currentTimeLabel.text = format(time: currentTime)
        totalTimeLabel.text = format(time: totalTime)
    }
    
    func player(_ player: YTTPlayerTools, cacheTime: TimeInterval, totalTime: TimeInterval) {
        
    }
    
    func player(_ player: YTTPlayerTools, startPlayAt index: Int) {
        let info = data[index]
        titleLabel.text = info.title
        singerLabel.text = info.singer
    }
    
    
    func format(time: TimeInterval) -> String {
        
        guard time > 0 else {
            return "0:00"
        }
        
        let secon = Int(time)
        let m = secon / 60
        let s = String(format: "%02d", secon % 60)
        
        return "\(m):\(s)"
        
        
    }
   
    
    
}

