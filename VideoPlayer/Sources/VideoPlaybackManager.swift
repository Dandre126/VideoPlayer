//
// Created by Nominalista on 29.10.2017.
// Copyright (c) 2017 Nominalista. All rights reserved.
//

import Foundation
import RxSwift

private let playbackStartDelay: RxTimeInterval = 0.3

public class VideoPlaybackManager: NSObject {

    private let settings: VideoPlaybackSettings
    private let notificationCenter: NotificationCenter
    private let videoPlayer: VideoPlayer
    private let cache: VideoCache

    private var currentVideoURL: URL?

    private let disposeBag = DisposeBag()
    private var playbackStartDisposable: Disposable?
    private var cacheQueryDisposable: Disposable?

    public init(settings: VideoPlaybackSettings, notificationCenter: NotificationCenter) {
        self.settings = settings
        self.notificationCenter = notificationCenter
        self.videoPlayer = VideoPlayer(notificationCenter: notificationCenter)
        self.cache = settings.cache
        super.init()

        observeSettings()
        observeNotifications()
    }

    private func observeSettings() {
        settings.isPlayerMutedObservable
                .subscribe(onNext: { [weak self] in self?.videoPlayer.set(isMuted: $0) })
                .disposed(by: disposeBag)
    }

    private func observeNotifications() {
        notificationCenter.rx
                .notification(.UIApplicationWillEnterForeground)
                .subscribe(onNext: { [weak self] _ in self?.applicationWillEnterForeground() })
                .disposed(by: disposeBag)

        notificationCenter.rx
                .notification(.UIApplicationDidEnterBackground)
                .subscribe(onNext: { [weak self] _ in self?.applicationDidEnterBackground() })
                .disposed(by: disposeBag)
    }

    private func applicationWillEnterForeground() {
        if let _ = currentVideoURL {
            // Playback is not working just after app becomes active
            schedulePlaybackStart()
        }
    }

    private func schedulePlaybackStart() {
        playbackStartDisposable?.dispose()
        playbackStartDisposable = Completable.empty()
                .delay(playbackStartDelay, scheduler: MainScheduler.instance)
                .subscribe(onCompleted: { [weak self] in
                    self?.playbackStartDisposable = nil
                    self?.startPlayback()
                })
    }

    private func applicationDidEnterBackground() {
        if let _ = currentVideoURL {
            stopPlayback()
        }
    }

    // Current URL String

    public func configure(with videoURL: URL?) -> VideoPlayer {
        currentVideoURL = videoURL
        return videoPlayer
    }

    // Playback

    public func startPlayback() {
        guard let videoURL = currentVideoURL else {
            return
        }

        cacheQueryDisposable?.dispose()
        cacheQueryDisposable = cache.queryVideoAsset(with: videoURL)
                .subscribeOn(BackgroundScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] videoAsset in
                    self.cacheQueryDisposable = nil
                    self.videoPlayer.set(currentItem: VideoPlayerItem(asset: videoAsset))
                    self.videoPlayer.play()
                })
    }

    public func stopPlayback() {
        guard let _ = currentVideoURL else {
            return
        }

        cacheQueryDisposable?.dispose()
        cacheQueryDisposable = nil
        videoPlayer.stop()
        videoPlayer.set(currentItem: nil)
    }

    // Cache

    public func startCachingVideo(with url: URL) {
        cache.startCachingVideo(with: url)
    }

    public func stopCachingVideo(with url: URL) {
        cache.stopCachingVideo(with: url)
    }

    // Volume

    public func changeMuting() {
        let isMuted = videoPlayer.isMuted.value
        settings.isPlayerMutedObservable.accept(!isMuted)
        videoPlayer.set(isMuted: !isMuted)
    }
}