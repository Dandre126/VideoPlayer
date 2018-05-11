//
// Created by Nominalista on 23.01.2018.
// Copyright (c) 2018 Nominalista. All rights reserved.
//

import Foundation
import RxCocoa

public class VideoPlaybackSettings {

    public let cache: VideoCache
    public let isPlayerMutedObservable = BehaviorRelay(value: true)

    public init(cache: VideoCache) {
        self.cache = cache
    }
}