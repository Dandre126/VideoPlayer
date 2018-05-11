//
// Created by Nominalista on 26.01.2018.
// Copyright (c) 2018 Yestars. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

private let videoSubdirectoryName = "video"
private let videoExtension = "mp4"

public class VideoCache {

    private let fileManager: FileManager
    private var directoryURL: URL?
    private var pendingAssets = [URL: RemoteVideoAsset]()
    private let disposeBag = DisposeBag()

    public init(fileManager: FileManager) {
        self.fileManager = fileManager
        setupDirectoryURL()
    }

    private func setupDirectoryURL() {
        guard let cacheDirectoryURL = fileManager.cacheDirectoryURL() else {
            print("Can't access cache directory.")
            return
        }

        let url = cacheDirectoryURL.appendingPathComponent(videoSubdirectoryName, isDirectory: true)
        if fileManager.directoryExists(at: url) || fileManager.createDirectory(at: url) {
            self.directoryURL = url
        }
    }

    public func startCachingVideo(with url: URL) {
        filename(forVideoWith: url)
                .subscribeOn(BackgroundScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] filename in
                    self.cacheVideo(url: url, filename: filename)
                }).disposed(by: disposeBag)
    }

    private func cacheVideo(url: URL, filename: String) {
        let isCached = fileExists(with: filename)
        let isDownloading = pendingAssets.hasValue(for: url)

        if !isCached, !isDownloading {
            let downloader = RemoteVideoAssetDownloader(url: url)
            downloader.delegate = self
            downloader.download()

            let asset = RemoteVideoAsset(url: url)
            asset.downloader = downloader

            pendingAssets[url] = asset
        }
    }

    public func stopCachingVideo(with url: URL) {
        filename(forVideoWith: url)
                .subscribeOn(BackgroundScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] filename in
                    _ = self.removeFile(with: filename)
                    _ = self.pendingAssets.removeValue(forKey: url)
                }).disposed(by: disposeBag)
    }

    func queryVideoAsset(with url: URL) -> Single<VideoAsset> {
        return filename(forVideoWith: url)
                .map { [unowned self] filename in
                    if self.fileExists(with: filename), let fileURL = self.fileURL(with: filename) {
                        return VideoAsset(url: fileURL)
                    } else if let asset = self.pendingAssets[url] {
                        return asset
                    } else {
                        return VideoAsset(url: url)
                    }
                }
    }

    public func clear() {
        if let directoryURL = directoryURL {
            _ = fileManager.removeDirectory(at: directoryURL)
        }
        pendingAssets.removeAll()

        setupDirectoryURL()
    }
}

// Utilities

extension VideoCache {

    private func filename(forVideoWith url: URL) -> Single<String> {
        return Single.create { observer in
            let filename = "\(url.absoluteString.md5()).\(videoExtension)"
            observer(.success(filename))
            return Disposables.create()
        }
    }

    private func fileURL(with name: String) -> URL? {
        return directoryURL?.appendingPathComponent(name)
    }

    private func fileExists(with name: String) -> Bool {
        if let url = fileURL(with: name) {
            return fileManager.fileExists(at: url)
        }
        return false
    }

    private func createFile(from data: Data, with name: String) -> Bool {
        if let url = fileURL(with: name) {
            return fileManager.createFile(from: data, at: url)
        }
        return false
    }

    private func removeFile(with name: String) -> Bool {
        if let url = fileURL(with: name) {
            return fileManager.removeFile(at: url)
        }
        return false
    }
}

extension VideoCache: RemoteVideoAssetDownloaderDelegate {

    public func remoteVideoAssetDownloader(_ remoteVideoAssetDownloader: RemoteVideoAssetDownloader,
                                           didDownload data: Data) {
        let url = remoteVideoAssetDownloader.url
        filename(forVideoWith: url)
                .subscribeOn(BackgroundScheduler.instance)
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: { [unowned self] filename in
                    _ = self.createFile(from: data, with: filename)
                    _ = self.pendingAssets.removeValue(forKey: url)
                }).disposed(by: disposeBag)
    }
}