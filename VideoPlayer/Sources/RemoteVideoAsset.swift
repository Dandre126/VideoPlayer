//
// Created by Nominalista on 31.01.2018.
// Copyright (c) 2018 Yestars. All rights reserved.
//

import AVFoundation
import Foundation

private let scheme = "remoteVideoAssetScheme"

public class RemoteVideoAsset: VideoAsset {

    public var downloader: RemoteVideoAssetDownloader? {
        didSet {
            resourceLoader.setDelegate(downloader, queue: DispatchQueue.main)
        }
    }

    override public init(url: URL) {
        super.init(url: url.with(scheme: scheme) ?? url)
    }
}
