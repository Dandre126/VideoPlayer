//
// Created by Nominalista on 02.05.2018.
// Copyright (c) 2018 Nominalista. All rights reserved.
//

import AVFoundation
import AVKit
import Foundation
import RxCocoa
import RxSwift

public class VideoPlayer: NSObject {
    
    public enum Status {
        case stopped
        case loading
        case playing
    }
    
    public let player = AVPlayer()
    public let status = BehaviorRelay(value: Status.stopped)
    public let isMuted = BehaviorRelay(value: true)
    
    private let notificationCenter: NotificationCenter
    private let disposeBag = DisposeBag()
    
    public init(notificationCenter: NotificationCenter) {
        self.notificationCenter = notificationCenter
        super.init()
        setupPlayer()
        observeNotifications()
    }
    
    private func setupPlayer() {
        player.isMuted = true
        player.automaticallyWaitsToMinimizeStalling = true
    }
    
    private func observeNotifications() {
        notificationCenter.rx
            .notification(.AVPlayerItemDidPlayToEndTime)
            .subscribe(onNext: { [weak self] _ in
                self?.playingFinished()
            })
            .disposed(by: disposeBag)
    }
    
    private func playingFinished() {
        if let _ = player.currentItem {
            player.seek(to: kCMTimeZero)
            player.play()
        }
    }
    
    deinit {
        if let currentItem = player.currentItem {
            removeObservers(from: currentItem)
        }
    }
    
    // Current item
    
    public func set(currentItem item: VideoPlayerItem?) {
        player.replaceCurrentItem(with: item)
    }
    
    // Playback
    
    public func play() {
        guard let currentItem = player.currentItem as? VideoPlayerItem else {
            print("No item to play.")
            return
        }
        
        addObservers(to: currentItem)
        if currentItem.isRemote {
            status.accept(.loading)
        }
        
        player.play()
    }
    
    private func addObservers(to item: AVPlayerItem) {
        item.addObserver(self, forKeyPath: .status, options: NSKeyValueObservingOptions(), context: nil)
        item.addObserver(self, forKeyPath: .playbackLikelyToKeepUp, options: NSKeyValueObservingOptions(), context: nil)
    }
    
    public func stop() {
        if let currentItem = player.currentItem {
            removeObservers(from: currentItem)
        }
        status.accept(.stopped)
        player.pause()
    }
    
    private func removeObservers(from item: AVPlayerItem) {
        item.removeObserver(self, forKeyPath: .status)
        item.removeObserver(self, forKeyPath: .playbackLikelyToKeepUp)
    }

    public func set(isMuted: Bool) {
        self.player.isMuted = isMuted
        self.isMuted.accept(isMuted)
    }
    
    public override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let currentItem = player.currentItem else {
            return
        }
        
        // TODO: Check if it's not called too often
        if isItemReadyToPlay(item: currentItem) {
            status.accept(.playing)
        }
    }
    
    private func isItemReadyToPlay(item: AVPlayerItem) -> Bool {
        return item.status == .readyToPlay && item.isPlaybackLikelyToKeepUp
    }
}

fileprivate extension String {
    
    static let status = "status"
    static let playbackLikelyToKeepUp = "playbackLikelyToKeepUp"
}
