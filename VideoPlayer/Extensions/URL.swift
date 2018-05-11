//
// Created by Nominalista on 11.05.2018.
// Copyright (c) 2018 Nominalista. All rights reserved.
//

extension URL {

    func with(scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}