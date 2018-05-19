//
//  TopTracksService.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import Foundation

struct TopTracksService {
    static let routeURL = "https://api.spotify.com/v1/artists/{id}/top-tracks"
    static func getTopTracks(with accessToken: String, artistId: String, country: String, completionHandler: @escaping ((Tracks?, Error?) -> Void)) {

        let url = routeURL.replacingOccurrences(of: "{id}", with: artistId)

        let parameters = ["country": country]
        var components = URLComponents(string: url)!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: components.url!)

        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    completionHandler(nil, error)
                    return
            }

            do {
                let jsonDecoder = JSONDecoder()
                let responseObject = try jsonDecoder.decode(Tracks.self, from: data)
                completionHandler(responseObject, nil)
            } catch {
                completionHandler(nil, error)
            }
        }
        task.resume()
    }
}
