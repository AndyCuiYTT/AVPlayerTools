//
//  YTTPlayerView.swift
//  AVPlayerTools
//
//  Created by AndyCui on 2018/9/30.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit
import AVFoundation

enum YTTFullScreenState {
    case small
    case full
}

class YTTPlayerView: UIView {
    
    private let player = AVPlayer()
    lazy private var playerLayer: AVPlayerLayer = {
        let layer = AVPlayerLayer(player: player)
        layer.frame = self.bounds
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return layer
    }()
    private var currentPlayItem: AVPlayerItem?
    private var timeObserver: Any?
    private var autoPlay: Bool = true


    private var fullScreenState: YTTFullScreenState = .small
    private var parentView: UIView?
    private var smallFrame: CGRect = CGRect.zero
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        return label
    }()
    private let topBgView = UIView()
    private let bottomBgView = UIView()
    private let currentTimeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.white
        return timeLabel
    }()
    
    private let totalTimeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.white
        return timeLabel
    }()
    
    private lazy var cacheShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.backgroundColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
    private lazy var playedShapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.backgroundColor = UIColor.blue.cgColor
        return shapeLayer
    }()
    
    private let playBtn = UIButton(type: UIButton.ButtonType.custom)
    
    private lazy var sliderView: UIView = {
        let subView = UIView()
        subView.backgroundColor = UIColor.gray
        subView.layer.addSublayer(cacheShapeLayer)
        subView.layer.addSublayer(playedShapeLayer)
        return subView
    }()
    
    private lazy var topGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.6).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        topBgView.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }()
    
    private lazy var bottomGradientLayer: CAGradientLayer = {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        bottomBgView.layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        
        self.layer.insertSublayer(playerLayer, at: 0)
        
        
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationExchane), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        // 播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(finish), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        // 播放时间监听
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            if let totalTime = self?.currentPlayItem?.duration {
                self?.currentTimeLabel.text = self?.format(time: cmTime.seconds)
                self?.totalTimeLabel.text = self?.format(time: totalTime.seconds)
                
                
                
                if let width = self?.sliderView.bounds.width, (cmTime.seconds / totalTime.seconds) > 0 {
                    // playedShapeLayer 播放进度条
                    self?.playedShapeLayer.frame = CGRect(x: 0, y: 0, width: width * CGFloat(cmTime.seconds / totalTime.seconds), height: 2)
                }
            }
        })
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deviceOrientationExchane(notification : Notification) {
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            break
        case .landscapeRight:
            break
        default:
            break
        }  
    }
    
    
    private func setupSubviews() {
        self.backgroundColor = UIColor.cyan
        
        topBgView.translatesAutoresizingMaskIntoConstraints = false
        bottomBgView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(topBgView)
        self.addSubview(bottomBgView)
        
        
        
        let topHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[topBgView]|", options: [], metrics: nil, views: ["topBgView": topBgView])
        let bottomHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomBgView]|", options: [], metrics: nil, views: ["bottomBgView": bottomBgView])
        
        let VConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[topBgView(40)]-(>=0)-[bottomBgView(40)]|", options: [], metrics: nil, views: ["topBgView" : topBgView, "bottomBgView": bottomBgView])
        
        self.addConstraints(topHConstraint)
        self.addConstraints(VConstraint)
        self.addConstraints(bottomHConstraint)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        topBgView.addSubview(titleLabel)
        
        let titleLabelHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[titleLabel]-(>=10)-|", options: [], metrics: nil, views: ["titleLabel": titleLabel])
        let titleLabelVConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", options: [], metrics: nil, views: ["titleLabel": titleLabel])
        
        topBgView.addConstraints(titleLabelHConstraint)
        topBgView.addConstraints(titleLabelVConstraint)
        
        
        
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        playBtn.setImage(UIImage(named: "play"), for: .selected)
        playBtn.setImage(UIImage(named: "pause"), for: .normal)
        playBtn.addTarget(self, action: #selector(playOrPauseAction(_:)), for: .touchUpInside)
        bottomBgView.addSubview(playBtn)
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.text = "0:00"
        bottomBgView.addSubview(currentTimeLabel)
        
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        bottomBgView.addSubview(sliderView)
        
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.text = "0:00"
        bottomBgView.addSubview(totalTimeLabel)
        
        let fullScreenBtn = UIButton(type: UIButton.ButtonType.custom)
        fullScreenBtn.translatesAutoresizingMaskIntoConstraints = false
        fullScreenBtn.setImage(UIImage(named: "close_fullscreen"), for: .selected)
        fullScreenBtn.setImage(UIImage(named: "open_fullscreen"), for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(enterFullScreen(_:)), for: .touchUpInside)
        bottomBgView.addSubview(fullScreenBtn)
        
        let bottomSubViewHConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[playBtn(20)]-15-[currentTimeLabel]-10-[sliderView]-10-[totalTimeLabel]-15-[fullScreenBtn(20)]-10-|", options: [], metrics: nil, views: ["playBtn": playBtn, "currentTimeLabel": currentTimeLabel, "sliderView": sliderView, "totalTimeLabel": totalTimeLabel, "fullScreenBtn": fullScreenBtn])
        
        let playCenterYConstraint = NSLayoutConstraint(item: playBtn, attribute: .centerY, relatedBy: .equal, toItem: bottomBgView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let playHeightConstraint = NSLayoutConstraint(item: playBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        
        let currentTimeCenterYConstraint = NSLayoutConstraint(item: currentTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: bottomBgView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let sliderViewCenterYConstraint = NSLayoutConstraint(item: sliderView, attribute: .centerY, relatedBy: .equal, toItem: bottomBgView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let sliderViewHeightConstraint = NSLayoutConstraint(item: sliderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 2)
        
        let totalTimeCenterYConstraint = NSLayoutConstraint(item: totalTimeLabel, attribute: .centerY, relatedBy: .equal, toItem: bottomBgView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let fullScreenCenterYConstraint = NSLayoutConstraint(item: fullScreenBtn, attribute: .centerY, relatedBy: .equal, toItem: bottomBgView, attribute: .centerY, multiplier: 1, constant: 0)
        
        let fullScreenHeightConstraint = NSLayoutConstraint(item: fullScreenBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 20)
        
        bottomBgView.addConstraints(bottomSubViewHConstraint)
        bottomBgView.addConstraints([playCenterYConstraint, playHeightConstraint, currentTimeCenterYConstraint, sliderViewCenterYConstraint, sliderViewHeightConstraint, totalTimeCenterYConstraint, fullScreenCenterYConstraint, fullScreenHeightConstraint])

    }
    
    
    @objc private func enterFullScreen(_ sender: UIButton) {
        if fullScreenState == .small {
            /*
             * 记录进入全屏前的parentView和frame
             */
            parentView = self.superview
            smallFrame = self.frame
            
            if let window = UIApplication.shared.keyWindow {
                
                /*
                 * movieView移到window上
                 */
                let rectInWindow =  self.convert(self.frame, to: window)
                self.removeFromSuperview()
                self.frame = rectInWindow;
                window.addSubview(self)
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.bounds = CGRect(x: 0, y: 0, width: window.frame.height, height: window.frame.width)
                    self.center = CGPoint(x: window.bounds.midX, y: window.bounds.midY)
                    self.playerLayer.frame = self.bounds
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                    })
                }) { [weak self] (finish) in
                    self?.fullScreenState = .full
                    sender.isSelected = true
                }
            }
        } else {
            
//            let smallRect = self.convert(self.frame, to: parentView)
            UIView.animate(withDuration: 0.2, animations: {
                self.transform = CGAffineTransform.identity
                self.frame = self.smallFrame
                self.playerLayer.frame = self.bounds

            }) { (finish) in
                self.removeFromSuperview()
                self.parentView?.addSubview(self)
                self.fullScreenState = .small
                sender.isSelected = false
            }
            
        }
        
    }
    
    @objc func playOrPauseAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            play()
        } else {
            sender.isSelected = true
            pause()
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = topBgView.bounds
        bottomGradientLayer.frame = bottomBgView.bounds
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        currentPlayItem?.removeObserver(self, forKeyPath: "status")
        currentPlayItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
    }
    

}

extension YTTPlayerView {

    func exchangePlayerItem(title: String, url: URL, autoPlay: Bool = true) {
        titleLabel.text = title
        
        let asset = AVAsset(url: url)
        guard asset.isPlayable else{
            return
        }
        let playItem = AVPlayerItem(asset: asset)
        currentPlayItem?.removeObserver(self, forKeyPath: "status")
        currentPlayItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        
        // 监听 playerItem 状态变化
        playItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        // 监听缓存时间
        playItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.player.replaceCurrentItem(with: playItem)
        
        currentPlayItem = playItem
    }
    
    @objc func play() {
        player.play()
        
    }
    
    @objc func pause() {
        player.pause()
    }
    
    @objc func finish() {
        playBtn.isSelected = true
        player.seek(to: CMTime(seconds: 0, preferredTimescale: CMTimeScale(kCMTimeMaxTimescale)))
        playedShapeLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 2)
    }
    
    
    
    
    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is AVPlayerItem {
            if keyPath == "status" {
                if let playerItem = object as? AVPlayerItem {
                    switch playerItem.status {
                    case .readyToPlay:
                        if autoPlay {
                            play()
                        }
                    case .failed:
                        print("加载失败")
                    default:
                        print("加载")
                    }
                }
            }
            
            if keyPath == "loadedTimeRanges" {
                if let playerItem = object as? AVPlayerItem {
                    if let timeRange = playerItem.loadedTimeRanges.first as? CMTimeRange {
                        // playedShapeLayer 加载进度条
                        if playerItem.duration.seconds > 0 {
                            cacheShapeLayer.frame = CGRect(x: 0, y: 0, width: self.sliderView.bounds.width * CGFloat((timeRange.start.seconds + timeRange.duration.seconds) / playerItem.duration.seconds), height: 2)
                        }
                    }
                }
            }
        }
    }
    
}

extension YTTPlayerView {
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


