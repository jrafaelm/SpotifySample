//
//  URL+QueryParams.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import Foundation
extension URL {

    public var spotifyParams: [String: String]? {
        let string = self.absoluteString.replacingOccurrences(of: "sample:spotifysample%23", with: "")
        let paramsSplit = string.split(separator: "&")

        var parameters = [String: String]()
        for item in paramsSplit.enumerated() {
            let keyValue = item.element.split(separator: "=")
            if keyValue.count == 2 {
                let key = String(keyValue[0])
                let value = String(keyValue[1])
                parameters[key] = value
            }
        }

        return parameters
    }
}
