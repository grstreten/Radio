//
//  ViewController.swift
//  Radio
//
//  Created by George on 27/12/2016.
//  Copyright © 2016 George Streten. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let tiles : [[String:String]] = [["name":"BBC R1","url":"http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio1_mf_p","artwork":"BBCR1Artwork","caption":"United Kingdom","type":"radio"],
                                        ["name":"BBC R2","url":"http://bbcmedia.ic.llnwd.net/stream/bbcmedia_radio2_mf_p","artwork":"BBCR2Artwork","caption":"United Kingdom","type":"radio"],
                                        ["name":"Mix 94.5","url":"http://stream.scahw.com.au/live/6mix_128.stream/playlist.m3u8","artwork":"MixArtwork","caption":"Perth, WA","type":"radio"],
                                        ["name":"Coast FM","url":"http://stream.coastlive.com.au","artwork":"CoastArtwork","caption":"Perth, WA","type":"radio"],
                                        ["name":"Spotify","url":"spotify://","artwork":"SpotifyArtwork","type":"app"],
                                        ["name":"Waze","url":"waze://","artwork":"WazeArtwork","type":"app"]]
    var player = AVPlayer()
    var playingIndex = 99
    
    @IBOutlet weak var collectionViewOutlet: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            NSLog("Success in AVAudioSession setup")
        } catch {
            NSLog("Failiure in AVAudioSession setup")
        }
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.addTarget(handler: {_ in
            self.player.play()
            return MPRemoteCommandHandlerStatus.success
        })
        commandCenter.pauseCommand.addTarget(handler: {_ in
            self.player.pause()
            return MPRemoteCommandHandlerStatus.success
        })
        
        updateUI()
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.updateUI), userInfo: nil, repeats: true)
    }
    
    func updateUI(){
        if playingIndex != 99 {
            if player.timeControlStatus == AVPlayerTimeControlStatus.paused {
                let pauseItemView = collectionViewOutlet.visibleCells[playingIndex].viewWithTag(2) as! UIImageView
                pauseItemView.alpha = 0.0
            } else if player.timeControlStatus == AVPlayerTimeControlStatus.playing {
                let pauseItemView = collectionViewOutlet.visibleCells[playingIndex].viewWithTag(2) as! UIImageView
                pauseItemView.alpha = 1.0
            }
        }
    }
    
    func playItemAtIndex(index: Int){
        let station = tiles[index]
        
        let url = station["url"]!
        let playerItem = AVPlayerItem(url:NSURL(string: url) as! URL)
        
        player = AVPlayer(playerItem:playerItem)
        player.rate = 1.0;
        player.play()
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let image:UIImage = UIImage(named: station["artwork"]!)!
        let artwork = MPMediaItemArtwork.init(boundsSize: image.size, requestHandler: { (size) -> UIImage in
            return image
        })
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyArtist: station["caption"]! as String,
            MPMediaItemPropertyTitle: station["name"]! as String,
            MPMediaItemPropertyArtwork: artwork
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playStationFromControl() {
        player.play()
    }

    func pauseStationFromControl() {
        player.pause()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tile = tiles[indexPath.row]
        NSLog("Tapped \(tile["name"]!)")

        if tile["type"] == "radio"{
            let tappedCell = collectionView.cellForItem(at: indexPath)
            
            if playingIndex == 99 { //Then play something
                let pauseItemView = tappedCell?.viewWithTag(2) as! UIImageView
                pauseItemView.alpha = 1.0
                
                playItemAtIndex(index: indexPath.row)
                playingIndex = indexPath.row
            } else if indexPath.row == playingIndex { //Then stop playing
                for cell in collectionView.visibleCells{
                    let pauseItemView = cell.viewWithTag(2) as! UIImageView
                    pauseItemView.alpha = 0.0
                }
                playingIndex = 99
                player.replaceCurrentItem(with: nil)
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            } else if indexPath.row != playingIndex { //Then change what is playing
                for cell in collectionView.visibleCells{
                    let pauseItemView = cell.viewWithTag(2) as! UIImageView
                    pauseItemView.alpha = 0.0
                }
                
                let pauseItemView = tappedCell?.viewWithTag(2) as! UIImageView
                pauseItemView.alpha = 1.0
                
                playItemAtIndex(index: indexPath.row)
                playingIndex = indexPath.row
            }
        } else if tile["type"] == "app"{
            UIApplication.shared.open(NSURL(string: tile["url"]!) as! URL, options: [:], completionHandler: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "item", for: indexPath) as UICollectionViewCell
        
        let imageView = item.viewWithTag(1) as! UIImageView
        imageView.image = UIImage(named: tiles[indexPath.row]["artwork"]!)!
        
        return item
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }

}

