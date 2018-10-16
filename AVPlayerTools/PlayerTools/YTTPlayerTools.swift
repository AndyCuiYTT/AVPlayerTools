//
//  YTTPlayerTools.swift
//  AVPlyerTools
//
//  Created by AndyCui on 2018/6/13.
//  Copyright © 2018年 AndyCuiYTT. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer


/**
 *
 *  如果在控制中心和锁屏页面不需要上一曲下一曲,只需要注释掉 MPRemoteCommandCenter 的监听上一曲下一曲,不要忘记 deinit 中的移除监听相关操作. 如果不添加任何操作将显示全部按钮.
 *
 *  如需后台播放在线音频参考 AppDelegate.
 */


/// 音视频播放处理回调
protocol YTTPlayerProtocol: class {
    
    
    /// 歌曲播放进度
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - currentTime: 当前播放时间
    ///   - totalTime: 总时长
    func player(_ player: YTTPlayerTools, currentTime: TimeInterval, totalTime: TimeInterval)
    
    /// 歌曲缓存时长
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - cacheTime: 当前缓存时间
    ///   - totalTime: 文件总时长
    func player(_ player: YTTPlayerTools, cacheTime: TimeInterval, totalTime: TimeInterval)
    
    
    /// 开始播放
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - index: 开始播放文件序列
    func player(_ player: YTTPlayerTools, startPlayAt index: Int)
    
    
    /// 播放失败
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - index: 播放失败文件序列
    func player(_ player: YTTPlayerTools, playFailedAt index: Int)
    
    
    /// 播放结束
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - index: 播放失败文件序列
    func player(_ player: YTTPlayerTools, playToEndTimeAt index: Int)
    
    /// 暂停播放,与后台控制一致
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - index: 暂停音频序列
    func player(_ player: YTTPlayerTools, pauseAt index: Int)
    
    
    /// 文件数量
    ///
    /// - Parameter player: 播放管理器
    /// - Returns: 要播放文件数量
    func numberOfMedia(_ player: YTTPlayerTools) -> Int
    
    
    /// 获取要播放文件信息
    ///
    /// - Parameters:
    ///   - player: 播放管理器
    ///   - index: 要播放文件序列
    /// - Returns: 要播放文件信息
    func player(_ player: YTTPlayerTools, playAt index: Int) -> YTTMediaInfo
}

extension YTTPlayerProtocol {
    
    func player(_ player: YTTPlayerTools, currentTime: TimeInterval, totalTime: TimeInterval){}
    
    func player(_ player: YTTPlayerTools, cacheTime: TimeInterval, totalTime: TimeInterval){}
    
    func player(_ player: YTTPlayerTools, startPlayAt index: Int){}
    
    func player(_ player: YTTPlayerTools, playFailedAt index: Int){}
    
    func player(_ player: YTTPlayerTools, playToEndTimeAt index: Int){}
    
    func player(_ player: YTTPlayerTools, pauseAt index: Int){}
}



/**
 *  开启子线程,将换歌放到子线程
 *  添加 AVAsset 检测,排除不可播放音频
 */

class YTTPlayerTools: NSObject {
    
    weak var delegate: YTTPlayerProtocol?
    private var currentPlayItem: AVPlayerItem?
    private var currentIndex = 0
    private var bgTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    private var timeObserver: Any?
    private(set) lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    
    
    private(set) var isPlaying: Bool = false
    
    
    init(allowBackground: Bool = true) {
        super.init()
        
        resetRemoteCommandCenter()
        
        if allowBackground {
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setActive(true)
                if #available(iOS 10.0, *) {
                    try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: [])
                } else {
                }
            } catch {
                print(error)
            }
        }
        
        // 播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(finish(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioSessionInterruption(_:)), name: AVAudioSession.interruptionNotification, object: nil)

        // 播放时间监听
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: DispatchQueue.main, using: { [weak self] (cmTime) in
            
            if cmTime.seconds > 0 && cmTime.seconds < 2 {
                if var dic = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                    dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self?.currentPlayItem?.currentTime().seconds ?? 0)
                    dic[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: self?.currentPlayItem?.duration.seconds ?? 0)
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
                }
            }
            
            if let totalTime = self?.currentPlayItem?.duration {
                self?.delegate?.player(self!, currentTime: cmTime.seconds, totalTime: totalTime.seconds)
            }
        })
        
    }
    
    
    /// 设置远程控制中心
    private func resetRemoteCommandCenter() {
        // 声明接收Remote Control事件
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // 响应 Remote Control事件
        MPRemoteCommandCenter.shared().playCommand.addTarget(self, action: #selector(play))
        
        MPRemoteCommandCenter.shared().nextTrackCommand.addTarget(self, action: #selector(next))
        
        MPRemoteCommandCenter.shared().pauseCommand.addTarget(self, action: #selector(pause))
        
        MPRemoteCommandCenter.shared().previousTrackCommand.addTarget(self, action: #selector(previous))
    }
    
    
    /// 播放
    @objc func play() {
        player.play()
        delegate?.player(self, startPlayAt: currentIndex)
        isPlaying = true
        if var dic = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            dic[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.currentPlayItem?.currentTime().seconds ?? 0)
            dic[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: self.currentPlayItem?.duration.seconds ?? 0)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
        }
    }
    
    /// 暂停
    @objc func pause() {
        player.pause()
        isPlaying = false
        delegate?.player(self, pauseAt: currentIndex)
        if var dic = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            dic[MPNowPlayingInfoPropertyPlaybackRate] = 0.0
            dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.currentPlayItem?.currentTime().seconds ?? 0)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
        }
    }
    
    
    /// 播放速度
    ///
    /// - Parameter rate: <#rate description#>
    func rate(_ rate: Float) {
        player.rate = rate
        if var dic = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            dic[MPNowPlayingInfoPropertyPlaybackRate] = rate
            MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
        }
    }
    
    /// 下一曲
    @objc func next() {
        if let count = delegate?.numberOfMedia(self) {
            if currentIndex + 1 < count {
                exchagePlayItem(atIndex: currentIndex + 1)
            } else if currentIndex + 1 == count {
                exchagePlayItem(atIndex: 0)
            }
        }
    }
    
    /// 上一曲
    @objc func previous() {
        if currentIndex > 0 {
            exchagePlayItem(atIndex: currentIndex - 1)
        }else if currentIndex == 0 {
            if let count = delegate?.numberOfMedia(self) {
                exchagePlayItem(atIndex: count - 1)
            }
        }
    }
    
    
    /// 跳转到
    ///
    /// - Parameters:
    ///   - second: 跳转到时间
    ///   - continuePlay: 是否继续播放
    func currentTime(_ second: TimeInterval, continuePlay: Bool = true) {
        
        if let totalTime = currentPlayItem?.duration {
            guard totalTime.seconds > second else {
                return
            }
            player.pause()
            let time = CMTimeMakeWithSeconds(second, preferredTimescale: totalTime.timescale)
            player.seek(to: time, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (flag) in
                if continuePlay {
                    self.play()
                }
            })
            if var dic = MPNowPlayingInfoCenter.default().nowPlayingInfo {
                dic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: second)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = dic
            }
        }
    }
    
    
    /// 播放结束
    ///
    /// - Parameter notification: 通知
    @objc private func finish(_ notification: Notification) {
        isPlaying = false
        delegate?.player(self, playToEndTimeAt: currentIndex)
    }
    
    /// 音频播放被系统打断
    ///
    /// - Parameter notification: 通知消息
    @objc private func audioSessionInterruption(_ notification: Notification) {
        
        if let status = notification.userInfo?["AVAudioSessionInterruptionTypeKey"] as? Int {
            switch status {
//            case 0:
//                if let status = notification.userInfo?["AVAudioSessionInterruptionOptionKey"] as? Int {
//                    if status == 0 {
//                        if currentPlayItem?.status == .readyToPlay {
//                            play()
//                        }
//                    }
//                }
            case 1:
                pause()
            default:
                break
            }
        }
    }
    
    func exchagePlayItem(atIndex index: Int) {
        if let media = delegate?.player(self, playAt: index) {
            currentIndex = index
            
            DispatchQueue.init(label: "com.andy.cui.player", qos: .default, attributes: .concurrent).async {
                self.exchagePlayItem(media)
            }
        }
    }
    
    private func exchagePlayItem(_ mediaInfo: YTTMediaInfo) {
        isPlaying = false
        if let url = URL(string: mediaInfo.url) {
            let asset = AVAsset(url: url)
            guard asset.isPlayable else{
                delegate?.player(self, playFailedAt: currentIndex)
                return
            }
            let playItem = AVPlayerItem(asset: asset)
            currentPlayItem?.removeObserver(self, forKeyPath: "status")
            currentPlayItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
            
            // 监听 playerItem 状态变化
            playItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            // 监听缓存时间
            playItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
            DispatchQueue.main.async {
                self.player.replaceCurrentItem(with: playItem)
            }
            
            currentPlayItem = playItem
            setLockScreenPlayingInfo(mediaInfo)
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if object is AVPlayerItem {
            if keyPath == "status" {
                if let playerItem = object as? AVPlayerItem {
                    switch playerItem.status {
                    case .readyToPlay:
                        DispatchQueue.main.async {
                            self.play()
                        }
                    case .failed:
                        DispatchQueue.main.async {
                            self.delegate?.player(self, playFailedAt: self.currentIndex)
                        }
                        print("加载失败")
                    default:
                        print("加载")
                    }
                }
            }
            
            if keyPath == "loadedTimeRanges" {
                if let playerItem = object as? AVPlayerItem {
                    if let timeRange = playerItem.loadedTimeRanges.first as? CMTimeRange {
                        delegate?.player(self, cacheTime: timeRange.start.seconds + timeRange.duration.seconds, totalTime: playerItem.duration.seconds)
                    }
                }
            }
        }
    }
    
    func setLockScreenPlayingInfo(_ info: YTTMediaInfo) {
        // Now Playing Center可以在锁屏界面展示音乐的信息，也达到增强用户体验的作用。
        // https://www.jianshu.com/p/458b67f84f27
        var infoDic: [String : Any] = [:]
        infoDic[MPMediaItemPropertyTitle] = info.title
        infoDic[MPMediaItemPropertyArtist] = info.singer
        
        // 图片 URL 转 Image
        if let urlStr = info.image, let url = URL(string: urlStr) {
            do {
                let data = try Data(contentsOf: url)
                if let img = UIImage(data: data) {
                    infoDic[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: img)
                }
                
            } catch {
                
            }
            
        }
        
        infoDic[MPMediaItemPropertyPlaybackDuration] = 0
        infoDic[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
        infoDic[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDic
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
        
        currentPlayItem?.removeObserver(self, forKeyPath: "status")
        currentPlayItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        MPRemoteCommandCenter.shared().playCommand.removeTarget(self, action: #selector(play))
        MPRemoteCommandCenter.shared().nextTrackCommand.removeTarget(self, action: #selector(next))
        MPRemoteCommandCenter.shared().pauseCommand.removeTarget(self, action: #selector(pause))
        MPRemoteCommandCenter.shared().previousTrackCommand.removeTarget(self, action: #selector(previous))
        UIApplication.shared.endReceivingRemoteControlEvents()
    }
    
    
    
    
}

