//
//  ViewController.swift
//  SpotifySample
//
//  Created by Rafael Moraes on 19/05/18.
//  Copyright © 2018 Rafael Moraes. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    let spotifyClientId = "1ee4c3cb3a344017bec89af1d2e8d01f"
    let spotifyRedirectURL = "sample:spotifysample"
    let player = SPTAudioStreamingController.sharedInstance()
    let auth = SPTAuth.defaultInstance()

    fileprivate var isFirstRun = true
    fileprivate var playerView = PlayerView()

    fileprivate var selectedTrack: Track? {
        didSet {

            playerView.track = selectedTrack
            player?.playSpotifyURI(selectedTrack?.uri ?? "", startingWith: 0, startingWithPosition: 0, callback: { error in
                print(error)
            })
        }
    }

    fileprivate var tracks = [Track]() {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewContainer: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        auth?.clientID = spotifyClientId
        auth?.redirectURL = URL(string: spotifyRedirectURL)!
        auth?.sessionUserDefaultsKey = "current session"
        auth?.requestedScopes = [SPTAuthStreamingScope]

        do {
            try player?.start(withClientId: spotifyClientId)
            player?.delegate = self
            player?.playbackDelegate = self
        } catch {
            print(error)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if auth?.session?.expirationDate ?? Date() <= Date() {
            startSpotifyAuthFlow()
        } else {
            player?.login(withAccessToken: auth?.session?.accessToken ?? "")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.urlDidOpenCallback = { [weak self] url in
            if self?.auth?.canHandle(url) ?? false {
                self?.dismiss(animated: true, completion: nil)
                if let accessToken = url.spotifyParams?["access_token"],
                    let expiresIn = url.spotifyParams?["expires_in"] {
                    self?.auth?.session = SPTSession(userName: "TestUser", accessToken: accessToken,  expirationTimeInterval: TimeInterval(expiresIn) ?? 0)

                    self?.player?.login(withAccessToken: accessToken)
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        if isFirstRun {
            isFirstRun = false

            viewContainer.addSubview(playerView)
            playerView.snp.makeConstraints({ (make) -> Void in
                make.bottom.top.leading.trailing.equalTo(0)
            })
            playerView.btnPlayTapped = { [weak self] isPlaying in
                self?.player?.setIsPlaying(isPlaying, callback: { error in
                    print(error)
                })
            }
            playerView.didSlide = { [weak self] miliseconds in
                self?.player?.seek(to: miliseconds/1000 , callback: { error in
                    print(error)
                })
            }
        }
    }

    fileprivate func startSpotifyAuthFlow() {
        if auth?.session?.isValid() ?? false {
            player?.login(withAccessToken: auth?.session.accessToken)
        } else {
            let authURL = auth?.spotifyWebAuthenticationURL() ?? URL(string: "www.google.com")!
            let authViewController = SFSafariViewController(url: authURL)
            present(authViewController, animated: true, completion: nil)
        }
    }
}

extension ViewController: SPTAudioStreamingDelegate {

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print(error)
    }

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidLogin")
        let audioslaveId = "2ziB7fzrXBoh1HUPS6sVFn"
        let audioslaveCountry = "US"
        TopTracksService.getTopTracks(with: auth?.session.accessToken ?? "", artistId: audioslaveId, country: audioslaveCountry) { [weak self] response, error in
            self?.tracks = response?.items ?? []
        }
    }

    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("audioStreamingDidLogout")
    }
}

extension ViewController: SPTAudioStreamingPlaybackDelegate {
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        print("isPlaying: \(isPlaying)")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        print("didSeekToPosition:\(position)")
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TrackTableViewCell.identifier) as? TrackTableViewCell else {
            return UITableViewCell()
        }
        cell.track = tracks[indexPath.row]
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrack = tracks[indexPath.row]
    }
}

