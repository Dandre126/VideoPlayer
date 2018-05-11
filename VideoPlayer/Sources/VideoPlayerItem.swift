//
// Created by Nominalista on 29.10.2017.
// Copyright (c) 2017 Yestars. All rights reserved.
//

import Foundation
import AVFoundation

public class VideoPlayerItem: AVPlayerItem {

    public var isRemote: Bool {
        return asset is RemoteVideoAsset
    }

    public init(asset: VideoAsset) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: nil)
    }
}
