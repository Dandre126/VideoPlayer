//
// Created by Nominalista on 26.01.2018.
// Copyright (c) 2018 Nominalista. All rights reserved.
//

extension Dictionary {

    func hasValue(for key: Key) -> Bool {
        return self[key] != nil
    }
}