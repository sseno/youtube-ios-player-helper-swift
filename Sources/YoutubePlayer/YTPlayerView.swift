//
//  YTPlayerView.swift
//  YouTubeiOSPlayerHelper
//
//  Created by Sacha DSO on 01/05/2020.
//  Copyright © 2020 YouTube Developer Relations. All rights reserved.
//

// Copyright 2014 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

/**
* YTPlayerView is a custom UIView that client developers will use to include YouTube
* videos in their iOS applications. It can be instantiated programmatically, or via
* Interface Builder. Use the methods YTPlayerView::loadWithVideoId:,
* YTPlayerView::loadWithPlaylistId: or their variants to set the video or playlist
* to populate the view with.
*/
public class YTPlayerView: UIView {
    
    /** A delegate to be notified on playback events. */
    public weak var delegate: YTPlayerViewDelegate?
    
    var webView: UIWebView! = UIWebView()
    
    private var originURL: URL?
    private var initialLoadingView: UIView?
//    private static let frameworkBundle = Bundle(path: "\(Bundle(for: YTPlayerView.self).resourcePath!)/Assets.bundle")
    
    
    /**
     * This method loads the player with the given video ID.
     * This is a convenience method for calling YTPlayerView::loadPlayerWithVideoId:withPlayerVars:
     * without player variables.
     *
     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
     * To change the currently loaded video without reloading the entire UIWebView, use the
     * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
     *
     * @param videoId The YouTube video ID of the video to load in the player view.
     * @return YES if player has been configured correctly, NO otherwise.
     */
    func loadWith(videoId: String) -> Bool {
        return loadWith(videoId:videoId, playerVars: nil)
    }
    
    /**
    * This method loads the player with the given playlist ID.
    * This is a convenience method for calling YTPlayerView::loadWithPlaylistId:withPlayerVars:
    * without player variables.
    *
    * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
    * To change the currently loaded video without reloading the entire UIWebView, use the
    * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
    * family of methods.
    *
    * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
    * @return YES if player has been configured correctly, NO otherwise.
    */
    func loadWith(playlistId: String) -> Bool {
      return loadWith(playlistId: playlistId, playerVars: nil)
    }
    
    /**
     * This method loads the player with the given video ID and player variables. Player variables
     * specify optional parameters for video playback. For instance, to play a YouTube
     * video inline, the following playerVars dictionary would be used:
     *
     * @code
     * @{ @"playsinline" : @1 };
     * @endcode
     *
     * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
     * both strings and integers are valid values. The full list of parameters is defined at:
     *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
     *
     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
     * To change the currently loaded video without reloading the entire UIWebView, use the
     * YTPlayerView::cueVideoById:startSeconds:suggestedQuality: family of methods.
     *
     * @param videoId The YouTube video ID of the video to load in the player view.
     * @param playerVars An NSDictionary of player parameters.
     * @return YES if player has been configured correctly, NO otherwise.
     */
    @discardableResult
    public func loadWith(videoId: String, playerVars: [String: AnyHashable]? = [String:AnyHashable]()) -> Bool {
        let playerParams: [String : AnyHashable] = [ "videoId" : videoId, "playerVars" : playerVars ]
        return loadWith(playerParams: playerParams)
    }
    
    /**
     * This method loads the player with the given playlist ID and player variables. Player variables
     * specify optional parameters for video playback. For instance, to play a YouTube
     * video inline, the following playerVars dictionary would be used:
     *
     * @code
     * @{ @"playsinline" : @1 };
     * @endcode
     *
     * Note that when the documentation specifies a valid value as a number (typically 0, 1 or 2),
     * both strings and integers are valid values. The full list of parameters is defined at:
     *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
     *
     * This method reloads the entire contents of the UIWebView and regenerates its HTML contents.
     * To change the currently loaded video without reloading the entire UIWebView, use the
     * YTPlayerView::cuePlaylistByPlaylistId:index:startSeconds:suggestedQuality:
     * family of methods.
     *
     * @param playlistId The YouTube playlist ID of the playlist to load in the player view.
     * @param playerVars An NSDictionary of player parameters.
     * @return YES if player has been configured correctly, NO otherwise.
     */
    func loadWith(playlistId: String, playerVars: [String: AnyHashable]? = [String: AnyHashable]() ) -> Bool {
        // Mutable copy because we may have been passed an immutable config dictionary.
        var tempPlayerVars = playerVars!
        tempPlayerVars["listType"] = "playlist"
        tempPlayerVars["list"] = playlistId
        let playerParams = ["playerVars" : tempPlayerVars]
        return loadWith(playerParams: playerParams)
    }
    
    /**
     * This method loads an iframe player with the given player parameters. Usually you may want to use
     * -loadWithVideoId:playerVars: or -loadWithPlaylistId:playerVars: instead of this method does not handle
     * video_id or playlist_id at all. The full list of parameters is defined at:
     *   https://developers.google.com/youtube/player_parameters?playerVersion=HTML5.
     *
     * @param additionalPlayerParams An NSDictionary of parameters in addition to required parameters
     *                               to instantiate the HTML5 player with. This differs depending on
     *                               whether a single video or playlist is being loaded.
     * @return YES if successful, NO if not.
     */
    func loadWith(playerParams additionalPlayerParams: [String: AnyHashable]?) -> Bool {
        var playerCallbacks = [
            "onReady" : "onReady",
            "onStateChange" : "onStateChange",
            "onPlaybackQualityChange" : "onPlaybackQualityChange",
            "onError" : "onPlayerError"
        ]
        
        var playerParams = [String: AnyHashable]()
        if let additionalPlayerParams = additionalPlayerParams {
            for (k, v) in additionalPlayerParams {
                playerParams[k] = v
            }
        }
        
        if playerParams["height"] == nil {
            playerParams["height"] = "100%"
        }
        if playerParams["width"] == nil {
            playerParams["width"] = "100%"
        }

        playerParams["events"] = playerCallbacks

        if playerParams["playerVars"] != nil {
            var playerVars = playerParams["playerVars"] as! [String: AnyHashable]
            if let urlString = playerVars["origin"] as? String {
                self.originURL = URL(string: urlString)
            } else {
                self.originURL = URL(string:"about:blank")
            }
        } else {
            // This must not be empty so we can render a '{}' in the output JSON
            playerParams["playerVars"] = [String: AnyHashable]()
        }

        // Remove the existing webView to reset any state
        webView.removeFromSuperview()
        webView = createNewWebView()
        addSubview(webView)

        let error: NSError? = nil
        let path:String? = nil
        
//        path = Bundle(for: YTPlayerView.self).path(forResource: "YTPlayerView-iframe-player", ofType: "html", inDirectory: "Assets")
//        print(Bundle(for: YTPlayerView.self))
//        print(path)
//
//        // in case of using Swift and embedded frameworks, resources included not in main bundle,
//        // but in framework bundle
//        if (path == nil) {
//            path =  frameworkBundle?.path(forResource: "YTPlayerView-iframe-player", ofType: "html", inDirectory: "Assets")
//        }
//        print(path)
//
//        let embedHTMLTemplate = try! String(contentsOfFile: path!, encoding: .utf8)
        
        let embedHTMLTemplate = ytPlayerHTMLString
        
        if error != nil {
//            print("Received error rendering template: \(error)")
            return false
        }

        // Render the playerVars as a JSON dictionary.
        if let jsonData = try? JSONSerialization.data(withJSONObject: playerParams, options: JSONSerialization.WritingOptions.prettyPrinted), let playerVarsJsonString = String(data: jsonData, encoding: .utf8), let originURL = originURL {
            let embedHTML = String(format:embedHTMLTemplate, playerVarsJsonString)
            webView.loadHTMLString(embedHTML, baseURL: originURL)
            webView.delegate = self
            webView.allowsInlineMediaPlayback = true
            webView.mediaPlaybackRequiresUserAction = false
            
            if let initialLoadingView = delegate?.playerViewPreferredInitialLoadingView(playerView: self) {
                initialLoadingView.frame = self.bounds
                initialLoadingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(initialLoadingView)
                self.initialLoadingView = initialLoadingView
            }
            
            return true
        
        }
//        print("Attempted configuration of player with invalid playerVars: \(playerParams)")
        return false
    }
        
    // MARK: - Player controls
    
    // These methods correspond to their JavaScript equivalents as documented here:
    //   https://developers.google.com/youtube/iframe_api_reference#Playback_controls

    /**
     * Starts or resumes playback on the loaded video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#playVideo
     */
    func playVideo() {
        interpret("player.playVideo();")
    }
    
    /**
     * Pauses playback on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#pauseVideo
     */
    func pauseVideo() {
        if let url = URL(string: String(format:"ytplayer://onStateChange?data=%@", kYTPlayerStatePausedCode)) {
            notifyDelegateOfYouTubeCallbackUrl(url: url)
        }
        interpret("player.pauseVideo();")
    }
    
    /**
     * Stops playback on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#stopVideo
     */
    public func stopVideo() {
        interpret("player.stopVideo();")
    }
    
    /**
     * Seek to a given time on a playing video. Corresponds to this method from
     * the JavaScript API:
     *   https://developers.google.com/youtube/iframe_api_reference#seekTo
     *
     * @param seekToSeconds The time in seconds to seek to in the loaded video.
     * @param allowSeekAhead Whether to make a new request to the server if the time is
     *                       outside what is currently buffered. Recommended to set to YES.
     */
    public func seek(toSeconds: Float, allowSeekAhead: Bool) {
        let secondsValue: NSNumber = NSNumber(value: toSeconds)
        let allowSeekAheadValue = stringForJSBoolean(allowSeekAhead)
        let command = String(format: "player.seekTo(%@, %@);", secondsValue, allowSeekAheadValue)
        interpret(command)
    }
            
    /**
     * Private method to convert a Objective-C BOOL value to JS boolean value.
     *
     * @param boolValue Objective-C BOOL value.
     * @return JavaScript Boolean value, i.e. "true" or "false".
     */
    func stringForJSBoolean(_ boolValue: Bool) -> String {
      return boolValue ? "true" : "false";
    }
    
    // MARK: - Cueing controls
    
    // Queueing functions for videos. These methods correspond to their JavaScript
    // equivalents as documented here:
    //   https://developers.google.com/youtube/iframe_api_reference#Queueing_Functions
    
    /**
    * Cues a given video by its video ID for playback starting at the given time and with the
    * suggested quality. Cueing loads a video, but does not start video playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cueVideoById
    *
    * @param videoId A video ID to cue.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cueVideoById(_ videoId: String,
                      startSeconds: Float,
                      suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue:NSNumber = NSNumber(value: startSeconds)
        let qualityValue = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.cueVideoById('%@', %@, '%@');", videoId, startSecondsValue, qualityValue)
        interpret(javascript)
    }

    
    /**
    * Cues a given video by its video ID for playback starting and ending at the given times
    * with the suggested quality. Cueing loads a video, but does not start video playback. This
    * method corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cueVideoById
    *
    * @param videoId A video ID to cue.
    * @param startSeconds Time in seconds to start the video when playVideo() is called.
    * @param endSeconds Time in seconds to end the video after it begins playing.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cueVideoById(videoId: String,
                      startSeconds: Float,
                      endSeconds: Float,
                      suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value: startSeconds)
        let endSecondsValue = NSNumber(value :endSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.cueVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});", videoId, startSecondsValue, endSecondsValue, quality)
        interpret(javascript)
    }

    /**
    * Loads a given video by its video ID for playback starting at the given time and with the
    * suggested quality. Loading a video both loads it and begins playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadVideoById
    *
    * @param videoId A video ID to load and begin playing.
    * @param startSeconds Time in seconds to start the video when it has loaded.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadVideoById(videoId: String, startSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value:startSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.loadVideoById('%@', %@, '%@');", videoId, startSecondsValue, quality)
        interpret(javascript)
    }

    /**
    * Loads a given video by its video ID for playback starting and ending at the given times
    * with the suggested quality. Loading a video both loads it and begins playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadVideoById
    *
    * @param videoId A video ID to load and begin playing.
    * @param startSeconds Time in seconds to start the video when it has loaded.
    * @param endSeconds Time in seconds to end the video after it begins playing.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadVideoById(videoId: String, startSeconds: Float, endSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value:startSeconds)
        let endSecondsValue = NSNumber(value:endSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format:"player.loadVideoById({'videoId': '%@', 'startSeconds': %@, 'endSeconds': %@, 'suggestedQuality': '%@'});",videoId, startSecondsValue, endSecondsValue, quality)
        interpret(javascript)
    }

    /**
    * Cues a given video by its URL on YouTube.com for playback starting at the given time
    * and with the suggested quality. Cueing loads a video, but does not start video playback.
    * This method corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
    *
    * @param videoURL URL of a YouTube video to cue for playback.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cueVideoByURL(videoURL: String,
                       startSeconds: Float,
                       suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value: startSeconds)
        let qualityValue = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format:"player.cueVideoByUrl('%@', %@, '%@');", videoURL, startSecondsValue, qualityValue)
        interpret(javascript)
    }
    
    /**
    * Cues a given video by its URL on YouTube.com for playback starting at the given time
    * and with the suggested quality. Cueing loads a video, but does not start video playback.
    * This method corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cueVideoByUrl
    *
    * @param videoURL URL of a YouTube video to cue for playback.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param endSeconds Time in seconds to end the video after it begins playing.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cueVideoByURL(videoURL: String,
                       startSeconds: Float,
                       endSeconds: Float,
                       suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value: startSeconds)
        let endSecondsValue = NSNumber(value: endSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.cueVideoByUrl('%@', %@, %@, '%@');", videoURL, startSecondsValue, endSecondsValue, quality)
        interpret(javascript)
    }
    
    /**
    * Loads a given video by its video ID for playback starting at the given time
    * with the suggested quality. Loading a video both loads it and begins playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
    *
    * @param videoURL URL of a YouTube video to load and play.
    * @param startSeconds Time in seconds to start the video when it has loaded.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadVideoByURL(_ videoURL: String,
                        startSeconds: Float,
                        suggestedQuality: YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value:startSeconds)
        let qualityValue = stringForPlaybackQuality(suggestedQuality)
        let command = String(format: "player.loadVideoByUrl('%@', %@, '%@');", videoURL, startSecondsValue, qualityValue)
        interpret(command)
    }
    
    /**
    * Loads a given video by its video ID for playback starting and ending at the given times
    * with the suggested quality. Loading a video both loads it and begins playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadVideoByUrl
    *
    * @param videoURL URL of a YouTube video to load and play.
    * @param startSeconds Time in seconds to start the video when it has loaded.
    * @param endSeconds Time in seconds to end the video after it begins playing.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadVideoByURL(_ videoURL: String,
                        startSeconds: Float,
                        endSeconds: Float,
                        suggestedQuality:YTPlaybackQuality) {
        let startSecondsValue = NSNumber(value: startSeconds)
        let endSecondsValue = NSNumber(value: endSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
            let javascript = String(format:"player.loadVideoByUrl('%@', %@, %@, '%@');",
          videoURL, startSecondsValue, endSecondsValue, quality)
        interpret(javascript)
    }

    // MARK: - Cueing methods for lists

    // Queueing functions for playlists. These methods correspond to
    // the JavaScript methods defined here:
    //    https://developers.google.com/youtube/js_api_reference#Playlist_Queueing_Functions
    
    /**
    * Cues a given playlist with the given ID. The |index| parameter specifies the 0-indexed
    * position of the first video to play, starting at the given time and with the
    * suggested quality. Cueing loads a playlist, but does not start video playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cuePlaylist
    *
    * @param playlistId Playlist ID of a YouTube playlist to cue.
    * @param index A 0-indexed position specifying the first video to play.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cuePlaylistBy(playlistId: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        let playlistIdString = String(format: "'%@'", playlistId)
        cuePlaylist(cueingString: playlistIdString, index: index, startSeconds: startSeconds, suggestedQuality: suggestedQuality)
    }

    /**
    * Cues a playlist of videos with the given video IDs. The |index| parameter specifies the
    * 0-indexed position of the first video to play, starting at the given time and with the
    * suggested quality. Cueing loads a playlist, but does not start video playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#cuePlaylist
    *
    * @param videoIds An NSArray of video IDs to compose the playlist of.
    * @param index A 0-indexed position specifying the first video to play.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func cuePlaylistBy(videoIds:[String], index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        cuePlaylist(cueingString: stringFromVideoIdArray(videoIds: videoIds),
                    index: index,
                    startSeconds: startSeconds,
                    suggestedQuality: suggestedQuality)
    }
    
    /**
    * Loads a given playlist with the given ID. The |index| parameter specifies the 0-indexed
    * position of the first video to play, starting at the given time and with the
    * suggested quality. Loading a playlist starts video playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadPlaylist
    *
    * @param playlistId Playlist ID of a YouTube playlist to cue.
    * @param index A 0-indexed position specifying the first video to play.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadPlaylistBy(playlistId: String, index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        let playlistIdString = String(format: "'%@'", playlistId)
        loadPlaylist(cueingString: playlistIdString,
                     index: index,
                     startSeconds: startSeconds,
                     suggestedQuality: suggestedQuality)
    }
    
    /**
    * Loads a playlist of videos with the given video IDs. The |index| parameter specifies the
    * 0-indexed position of the first video to play, starting at the given time and with the
    * suggested quality. Loading a playlist starts video playback. This method
    * corresponds with its JavaScript API equivalent as documented here:
    *    https://developers.google.com/youtube/iframe_api_reference#loadPlaylist
    *
    * @param videoIds An NSArray of video IDs to compose the playlist of.
    * @param index A 0-indexed position specifying the first video to play.
    * @param startSeconds Time in seconds to start the video when YTPlayerView::playVideo is called.
    * @param suggestedQuality YTPlaybackQuality value suggesting a playback quality.
    */
    func loadPlaylistByVideos(videoIds: [String], index: Int, startSeconds: Float, suggestedQuality: YTPlaybackQuality) {
        loadPlaylist(cueingString: stringFromVideoIdArray(videoIds: videoIds),
                     index: index,
                     startSeconds: startSeconds,
                     suggestedQuality: suggestedQuality)
    }

    // MARK: - Setting the playback rate

    /**
    * Gets the playback rate. The default value is 1.0, which represents a video
    * playing at normal speed. Other values may include 0.25 or 0.5 for slower
    * speeds, and 1.5 or 2.0 for faster speeds. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate
    *
    * @return An integer value between 0 and 100 representing the current volume.
    */
    func playbackRate() -> Float {
        let value = interpret("player.getPlaybackRate();") ?? ""
        return (value as NSString).floatValue
    }

    /**
    * Sets the playback rate. The default value is 1.0, which represents a video
    * playing at normal speed. Other values may include 0.25 or 0.5 for slower
    * speeds, and 1.5 or 2.0 for faster speeds. To fetch a list of valid values for
    * this method, call YTPlayerView::getAvailablePlaybackRates. This method does not
    * guarantee that the playback rate will change.
    * This method corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#setPlaybackRate
    *
    * @param suggestedRate A playback rate to suggest for the player.
    */
    func setPlaybackRate(suggestedRate: Float) {
        let javascript = String(format: "player.setPlaybackRate(%f);", suggestedRate)
        interpret(javascript)
    }
    
    /**
    * Gets a list of the valid playback rates, useful in conjunction with
    * YTPlayerView::setPlaybackRate. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackRate
    *
    * @return An NSArray containing available playback rates. nil if there is an error.
    */
    func availablePlaybackRates() -> [String]? {
        let returnValue = interpret("player.getAvailablePlaybackRates();")
        if let playbackRateData = returnValue?.data(using: .utf8) {
            let playbackRates = try? JSONSerialization.jsonObject(with: playbackRateData, options: [])
            return playbackRates as? [String] ?? [String]()
        }
        return nil
    }
    
    // MARK: - Setting playback behavior for playlists

    /**
    * Sets whether the player should loop back to the first video in the playlist
    * after it has finished playing the last video. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#loopPlaylist
    *
    * @param loop A boolean representing whether the player should loop.
    */
    func setLoop(_ loop: Bool) {
        let loopPlayListValue = stringForJSBoolean(loop)
        let javascript = String(format: "player.setLoop(%@);", loopPlayListValue)
        interpret(javascript)
    }

    /**
    * Sets whether the player should shuffle through the playlist. This method
    * corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#shufflePlaylist
    *
    * @param shuffle A boolean representing whether the player should
    *                shuffle through the playlist.
    */
    func setShuffle(shuffle: Bool)  {
        let shufflePlayListValue = stringForJSBoolean(shuffle)
        let javascript = String(format: "player.setShuffle(%@);", shufflePlayListValue)
        interpret(javascript)
    }
    
    // MARK: - Playback status
    
    // These methods correspond to the JavaScript methods defined here:
    //    https://developers.google.com/youtube/js_api_reference#Playback_status

    
    /**
    * Returns a number between 0 and 1 that specifies the percentage of the video
    * that the player shows as buffered. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getVideoLoadedFraction
    *
    * @return A float value between 0 and 1 representing the percentage of the video
    *         already loaded.
    */
    func videoLoadedFraction() -> Float? {
        return Float(interpret("player.getVideoLoadedFraction();") ?? "")
    }

    /**
    * Returns the state of the player. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlayerState
    *
    * @return |YTPlayerState| representing the state of the player.
    */
    func playerState() -> YTPlayerState  {
      let value = interpret("player.getPlayerState();")
      return playerStateForString(value ?? "")
    }

    /**
    * Returns the elapsed time in seconds since the video started playing. This
    * method corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getCurrentTime
    *
    * @return Time in seconds since the video started playing.
    */
    func currentTime() -> Float? {
        return Float(interpret("player.getCurrentTime();") ?? "")
    }

    // MARK: - Playback quality
    

    // Playback quality. These methods correspond to the JavaScript
    // methods defined here:
    //   https://developers.google.com/youtube/js_api_reference#Playback_quality
    
    /**
    * Returns the playback quality. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlaybackQuality
    *
    * @return YTPlaybackQuality representing the current playback quality.
    */
    func playbackQuality() -> YTPlaybackQuality {
      let qualityValue = interpret("player.getPlaybackQuality();")
        return playbackQualityForString(qualityValue ?? "")
    }

    /**
    * Suggests playback quality for the video. It is recommended to leave this setting to
    * |default|. This method corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#setPlaybackQuality
    *
    * @param quality YTPlaybackQuality value to suggest for the player.
    */
    func setPlaybackQuality(suggestedQuality: YTPlaybackQuality) {
        let quality =  stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format:"player.setPlaybackQuality('%@');", quality)
        interpret(javascript)
    }

    
    // MARK: - Retrieving video information

    // Retrieving video information. These methods correspond to the JavaScript
    // methods defined here:
    //   https://developers.google.com/youtube/js_api_reference#Retrieving_video_information
    
    /**
    * Returns the duration in seconds since the video of the video. This
    * method corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getDuration
    *
    * @return Length of the video in seconds.
    */
    func duration() -> TimeInterval? {
        let value = interpret("player.getDuration();") ?? ""
        return TimeInterval(value)
    }

    /**
    * Returns the YouTube.com URL for the video. This method corresponds
    * to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getVideoUrl
    *
    * @return The YouTube.com URL for the video. Returns nil if no video is loaded yet.
    */
    func videoUrl() -> NSURL? {
        let val = interpret("player.getVideoUrl();")
        return NSURL(string: val ?? "")
    }

    /**
    * Returns the embed code for the current video. This method corresponds
    * to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getVideoEmbedCode
    *
    * @return The embed code for the current video. Returns nil if no video is loaded yet.
    */
    func videoEmbedCode() -> String {
      return interpret("player.getVideoEmbedCode();") ?? ""
    }

    // MARK: - Retrieving playlist information
    
    // Retrieving playlist information. These methods correspond to the
    // JavaScript defined here:
    //    https://developers.google.com/youtube/js_api_reference#Retrieving_playlist_information

    /**
    * Returns an ordered array of video IDs in the playlist. This method corresponds
    * to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlaylist
    *
    * @return An NSArray containing all the video IDs in the current playlist. |nil| on error.
    */
    func playlist() -> [String] {
        let returnValue = interpret("player.getPlaylist();")
        if let playlistData = returnValue?.data(using: .utf8) {
            let videoIds = try? JSONSerialization.jsonObject(with: playlistData, options: [])
            return videoIds as? [String] ?? [String]()
        }
        return [String]()
    }
    
    /**
    * Returns the 0-based index of the currently playing item in the playlist.
    * This method corresponds to the JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getPlaylistIndex
    *
    * @return The 0-based index of the currently playing item in the playlist.
    */
    func playlistIndex() -> Int {
        let returnValue = interpret("player.getPlaylistIndex();") ?? ""
        return Int(returnValue) ?? 0
    }

    // MARK: - Playing a video in a playlist
    
    // These methods correspond to the JavaScript API as defined under the
    // "Playing a video in a playlist" section here:
    //    https://developers.google.com/youtube/iframe_api_reference#Playback_status

    /**
    * Loads and plays the next video in the playlist. Corresponds to this method from
    * the JavaScript API:
    *   https://developers.google.com/youtube/iframe_api_reference#nextVideo
    */
    func nextVideo() {
        interpret("player.nextVideo();")
    }

    /**
    * Loads and plays the previous video in the playlist. Corresponds to this method from
    * the JavaScript API:
    *   https://developers.google.com/youtube/iframe_api_reference#previousVideo
    */
    func previousVideo() {
        interpret("player.previousVideo();")
    }

    /**
    * Loads and plays the video at the given 0-indexed position in the playlist.
    * Corresponds to this method from the JavaScript API:
    *   https://developers.google.com/youtube/iframe_api_reference#playVideoAt
    *
    * @param index The 0-indexed position of the video in the playlist to load and play.
    */
    func playVideoAt(index: Int) {
        let javascript = String(format: "player.playVideoAt(%@);", NSNumber(value: index))
        interpret(javascript)
    }

    
    /**
    * Gets a list of the valid playback quality values, useful in conjunction with
    * YTPlayerView::setPlaybackQuality. This method corresponds to the
    * JavaScript API defined here:
    *   https://developers.google.com/youtube/iframe_api_reference#getAvailableQualityLevels
    *
    * @return An NSArray containing available playback quality levels. Returns nil if there is an error.
    */
    func availableQualityLevels() -> [YTPlaybackQuality]? {
        guard let returnValue = interpret("player.getAvailableQualityLevels().toString();") else {
            return nil
        }
        let rawQualityValues = returnValue.components(separatedBy: ",")
        return rawQualityValues.map { playbackQualityForString($0) }
    }

    /**
     * Convert a quality value from NSString to the typed enum value.
     *
     * @param qualityString A string representing playback quality. Ex: "small", "medium", "hd1080".
     * @return An enum value representing the playback quality.
     */
    func playbackQualityForString(_ qualityString: String) -> YTPlaybackQuality {
        var quality:YTPlaybackQuality = .unknown
        if qualityString == kYTPlaybackQualitySmallQuality {
            quality = .small
        } else if qualityString == kYTPlaybackQualityMediumQuality {
            quality = .medium
        } else if qualityString == kYTPlaybackQualityLargeQuality {
            quality = .large
        } else if qualityString == kYTPlaybackQualityHD720Quality {
            quality = .hd720
        } else if qualityString == kYTPlaybackQualityHD1080Quality {
            quality = .hd1080
        } else if qualityString == kYTPlaybackQualityHighResQuality {
            quality = .highRes
        } else if qualityString == kYTPlaybackQualityAutoQuality {
            quality = .auto
        }
        return quality
    }

    /**
     * Convert a |YTPlaybackQuality| value from the typed value to NSString.
     *
     * @param quality A |YTPlaybackQuality| parameter.
     * @return An |NSString| value to be used in the JavaScript bridge.
     */
    func stringForPlaybackQuality(_ quality: YTPlaybackQuality) -> String {
      switch quality {
      case .small:
          return kYTPlaybackQualitySmallQuality
      case .medium:
          return kYTPlaybackQualityMediumQuality
      case .large:
          return kYTPlaybackQualityLargeQuality
      case .hd720:
          return kYTPlaybackQualityHD720Quality
      case .hd1080:
          return kYTPlaybackQualityHD1080Quality
      case .highRes:
          return kYTPlaybackQualityHighResQuality
      case .auto:
          return kYTPlaybackQualityAutoQuality
        default:
          return kYTPlaybackQualityUnknownQuality
      }
    }

    /**
     * Convert a state value from NSString to the typed enum value.
     *
     * @param stateString A string representing player state. Ex: "-1", "0", "1".
     * @return An enum value representing the player state.
     */
    func playerStateForString(_ stateString: String) -> YTPlayerState {
        var state: YTPlayerState = .unknown
        if stateString == kYTPlayerStateUnstartedCode {
            state = .unstarted
        } else if stateString == kYTPlayerStateEndedCode {
            state = .ended
        } else if stateString == kYTPlayerStatePlayingCode {
            state = .playing
        } else if stateString == kYTPlayerStatePausedCode {
            state = .paused
        } else if stateString == kYTPlayerStateBufferingCode {
            state = .buffering
        } else if stateString == kYTPlayerStateCuedCode {
            state = .queued
        }
        return state
    }

    /**
     * Convert a state value from the typed value to NSString.
     *
     * @param quality A |YTPlayerState| parameter.
     * @return A string value to be used in the JavaScript bridge.
     */
    func stringForPlayerState(_ state: YTPlayerState) -> String {
      switch state {
      case .unstarted:
          return kYTPlayerStateUnstartedCode
      case .ended:
          return kYTPlayerStateEndedCode
      case .playing:
          return kYTPlayerStatePlayingCode
      case .paused:
          return kYTPlayerStatePausedCode
      case .buffering:
          return kYTPlayerStateBufferingCode
      case .queued:
          return kYTPlayerStateCuedCode
        default:
          return kYTPlayerStateUnknownCode
      }
    }

    // MARK: - Private methods

    /**
     * Private method to handle "navigation" to a callback URL of the format
     * ytplayer://action?data=someData
     * This is how the UIWebView communicates with the containing Objective-C code.
     * Side effects of this method are that it calls methods on this class's delegate.
     *
     * @param url A URL of the format ytplayer://action?data=value.
     */
    private func notifyDelegateOfYouTubeCallbackUrl(url: URL)  {
        let action = url.host

        // We know the query can only be of the format ytplayer://action?data=SOMEVALUE,
        // so we parse out the value.
        let query = url.query
        var data = query?.components(separatedBy: "=").first

        if action == kYTPlayerCallbackOnReady {
            initialLoadingView?.removeFromSuperview()
            delegate?.playerViewDidBecomeReady(playerView: self)
        } else if action == kYTPlayerCallbackOnStateChange {
            var state = YTPlayerState.unknown
            if data == kYTPlayerStateEndedCode {
                state = .ended
            } else if data == kYTPlayerStatePlayingCode {
                state = .playing
            } else if data == kYTPlayerStatePausedCode {
                state = .paused
            } else if data == kYTPlayerStateBufferingCode {
                state = .buffering
            } else if data == kYTPlayerStateCuedCode {
                state = .queued
            } else if data == kYTPlayerStateUnstartedCode {
                state = .unstarted
            }
            delegate?.playerViewDidChangeToState(playerView: self, state: state)
        } else if action == kYTPlayerCallbackOnPlaybackQualityChange {
            let quality: YTPlaybackQuality = playbackQualityForString(data!)
            delegate?.playerViewDidChangeToQuality(playerView: self, quality: quality)
        } else if action == kYTPlayerCallbackOnError {
            var error: YTPlayerError = .unknown
            if data == kYTPlayerErrorInvalidParamErrorCode {
                error = .invalidParam
            } else if data == kYTPlayerErrorHTML5ErrorCode {
                error = .html5Error
            } else if data == kYTPlayerErrorNotEmbeddableErrorCode
                || data == kYTPlayerErrorSameAsNotEmbeddableErrorCode {
                error = .notEmbeddable
            } else if data == kYTPlayerErrorVideoNotFoundErrorCode
                || data == kYTPlayerErrorCannotFindVideoErrorCode {
                error = .videoNotFound
            }
            delegate?.playerViewReceivedError(playerView: self, error: error)
        } else if action == kYTPlayerCallbackOnPlayTime {
            var time: Float = (data as? NSString)?.floatValue ?? 0
            delegate?.playerViewDidPlayTime(playerView: self, playTime: time)
        } else if action == kYTPlayerCallbackOnYouTubeIframeAPIFailedToLoad {
            initialLoadingView?.removeFromSuperview()
        }
    }

    func handleHttpNavigationToUrl(url: URL) -> Bool {
      // Usually this means the user has clicked on the YouTube logo or an error message in the
      // player. Most URLs should open in the browser. The only http(s) URL that should open in this
      // UIWebView is the URL for the embed, which is of the format:
      //     http(s)://www.youtube.com/embed/[VIDEO ID]?[PARAMETERS]
      let ytRegex = try! NSRegularExpression(pattern: kYTPlayerEmbedUrlRegexPattern,
                                        options: NSRegularExpression.Options.caseInsensitive)
        
        let range = NSRange(location: 0, length: url.absoluteString.count)
        let ytMatch = ytRegex.firstMatch(in: url.absoluteString,
                                    options: [], range: range)
        
        let adRegex = try! NSRegularExpression(pattern: kYTPlayerAdUrlRegexPattern,
                                          options: NSRegularExpression.Options.caseInsensitive)
        let adMatch = adRegex.firstMatch(in: url.absoluteString,
                                    options: [], range: range)
        
        let syndicationRegex = try! NSRegularExpression(pattern: kYTPlayerSyndicationRegexPattern,
                                          options: NSRegularExpression.Options.caseInsensitive)
        let syndicationMatch = syndicationRegex.firstMatch(in: url.absoluteString,
                                    options: [], range: range)
        
        let oauthRegex = try! NSRegularExpression(pattern: kYTPlayerOAuthRegexPattern,
                                          options: NSRegularExpression.Options.caseInsensitive)
        let oauthMatch = oauthRegex.firstMatch(in: url.absoluteString,
                                    options: [], range: range)
        
        let staticProxyRegex = try! NSRegularExpression(pattern: kYTPlayerStaticProxyRegexPattern,
                                          options: NSRegularExpression.Options.caseInsensitive)
        let staticProxyMatch = staticProxyRegex.firstMatch(in: url.absoluteString,
                                    options: [], range: range)

      if (ytMatch != nil || adMatch != nil || oauthMatch != nil || staticProxyMatch != nil || syndicationMatch != nil) {
            return true
      } else {
            UIApplication.shared.openURL(url)
            return false
        }
    }

    /**
     * Private method for cueing both cases of playlist ID and array of video IDs. Cueing
     * a playlist does not start playback.
     *
     * @param cueingString A JavaScript string representing an array, playlist ID or list of
     *                     video IDs to play with the playlist player.
     * @param index 0-index position of video to start playback on.
     * @param startSeconds Seconds after start of video to begin playback.
     * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
     * @return The result of cueing the playlist.
     */
    func cuePlaylist(cueingString: String,
                     index: Int,
                     startSeconds: Float,
                     suggestedQuality: YTPlaybackQuality) {
        let indexValue = NSNumber(value: index)
        let startSecondsValue = NSNumber(value:startSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.cuePlaylist(%@, %@, %@, '%@');",
          cueingString, indexValue, startSecondsValue, quality)
        interpret(javascript)
    }

    /**
     * Private method for loading both cases of playlist ID and array of video IDs. Loading
     * a playlist automatically starts playback.
     *
     * @param cueingString A JavaScript string representing an array, playlist ID or list of
     *                     video IDs to play with the playlist player.
     * @param index 0-index position of video to start playback on.
     * @param startSeconds Seconds after start of video to begin playback.
     * @param suggestedQuality Suggested YTPlaybackQuality to play the videos.
     * @return The result of cueing the playlist.
     */
    func loadPlaylist(cueingString: String,
                      index: Int,
                      startSeconds: Float,
                      suggestedQuality: YTPlaybackQuality) {
        let indexValue = NSNumber(value: index)
        let startSecondsValue = NSNumber(value :startSeconds)
        let quality = stringForPlaybackQuality(suggestedQuality)
        let javascript = String(format: "player.loadPlaylist(%@, %@, %@, '%@');", cueingString, indexValue, startSecondsValue, quality)
        interpret(javascript)
    }

    /**
     * Private helper method for converting an NSArray of video IDs into its JavaScript equivalent.
     *
     * @param videoIds An array of video ID strings to convert into JavaScript format.
     * @return A JavaScript array in String format containing video IDs.
     */
    func stringFromVideoIdArray(videoIds: [String]) -> String {
       var formattedVideoIds = [String]()
        for unformattedId in videoIds {
            formattedVideoIds.append(String(format: "'%@'", unformattedId))
        }
        return String(format: "[%@]", formattedVideoIds.joined(separator: ", "))
    }

    /**
     * Private method for evaluating JavaScript in the WebView.
     *
     * @param jsToExecute The JavaScript code in string format that we want to execute.
     * @return JavaScript response from evaluating code.
     */
    @discardableResult
    func interpret(_ javascript: String) -> String? {
        return webView.stringByEvaluatingJavaScript(from: javascript)
    }


    func createNewWebView() -> UIWebView {
        let webView = UIWebView(frame: self.bounds)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight ]
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        if let color = delegate?.playerViewPreferredWebViewBackgroundColor(playerView: self) {
            webView.backgroundColor = color
            if color == .clear {
                webView.isOpaque = false
            }
        }
        return webView
    }

    /**
    * Removes the internal web view from this player view.
    * Intended to use for testing, should not be used in production code.
    */
    func removeWebView() {
        webView.removeFromSuperview()
        webView = nil
    }
}


extension YTPlayerView: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if request.url?.host == originURL?.host {
          return true
        } else if request.url?.scheme == "ytplayer" {
            notifyDelegateOfYouTubeCallbackUrl(url: request.url!)
            return false
        } else if request.url?.scheme == "http" || request.url?.scheme == "https" {
            return handleHttpNavigationToUrl(url: request.url!)
        }
        return true
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        initialLoadingView?.removeFromSuperview()
    }
}