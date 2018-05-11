//
// Created by Nominalista on 28.11.2017.
// Copyright (c) 2017 Nominalista. All rights reserved.
//

import RxSwift

class BackgroundScheduler {

    static let instance = ConcurrentDispatchQueueScheduler(qos: .background)
}
