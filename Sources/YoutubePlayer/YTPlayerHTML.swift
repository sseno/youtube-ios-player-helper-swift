//
//  YTPlayerHTML.swift
//  YouTubeiOSPlayerHelper
//
//  Created by Sacha DSO on 02/05/2020.
//  Copyright © 2020 YouTube Developer Relations. All rights reserved.
//

//Copyright 2014 Google Inc. All rights reserved.
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.


import Foundation

let ytPlayerHTMLString =
"""
<!DOCTYPE html>
<html>
    <head>
        <meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
        <style>
        body { margin: 0; width:100%%; height:100%%;  background-color:#000000; }
        html { width:100%%; height:100%%; background-color:#000000; }

        .embed-container iframe,
        .embed-container object,
        .embed-container embed {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%% !important;
            height: 100%% !important;
        }
        </style>
    </head>
    <body>
        <div class="embed-container">
            <div id="player"></div>
        </div>
        <script src="https://www.youtube.com/iframe_api" onerror="window.location.href='ytplayer://onYouTubeIframeAPIFailedToLoad'"></script>
        <script>
        var player;
        var error = false;

        YT.ready(function() {
            player = new YT.Player('player', %@);
            player.setSize(window.innerWidth, window.innerHeight);
            window.location.href = 'ytplayer://onYouTubeIframeAPIReady';

            // this will transmit playTime frequently while playng
            function getCurrentTime() {
                 var state = player.getPlayerState();
                 if (state == YT.PlayerState.PLAYING) {
                     time = player.getCurrentTime()
                     window.location.href = 'ytplayer://onPlayTime?data=' + time;
                 }
            }
            
            window.setInterval(getCurrentTime, 500);
                 
        });

        function onReady(event) {
            window.location.href = 'ytplayer://onReady?data=' + event.data;
        }

        function onStateChange(event) {
            if (!error) {
                window.location.href = 'ytplayer://onStateChange?data=' + event.data;
            }
            else {
                error = false;
            }
        }

        function onPlaybackQualityChange(event) {
            window.location.href = 'ytplayer://onPlaybackQualityChange?data=' + event.data;
        }

        function onPlayerError(event) {
            if (event.data == 100) {
                error = true;
            }
            window.location.href = 'ytplayer://onError?data=' + event.data;
        }
        
        window.onresize = function() {
            player.setSize(window.innerWidth, window.innerHeight);
        }
        </script>
    </body>
</html>
"""
