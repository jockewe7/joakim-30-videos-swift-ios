//
//  ViewController.swift
//  joakim-30-videos-swift-ios
//
//  Created by Fredrik Jonsson on 27/02/16.
//  Copyright © 2016 Fredrik Jonsson. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: AVPlayerViewController {
    
    override weak var preferredFocusedView: UIView? {
        return self.view
    }
    
    var mediaFiles = [String]()
    var currentIndex : Int = 0
    var scrollView : UIScrollView?
    
    override func viewDidLoad() {
        // Denna metod körs automatiskt när appen startas och ser till att den första vyn,
        // self.view har initierats. Det är i den vi lägger till alla saker vi vill visa senare
        super.viewDidLoad()
        
        // Det här är vår metod för att leta reta på alla media filer som finns bundlade i appen
        mediaFiles = extractFiles()
        
        // Vi ändrar till svart background för att slippa att det blinkar till när vi byter filmer
        self.view.backgroundColor = UIColor.blackColor()
        self.showsPlaybackControls = false
        
        // Vi sätter en klicklyssnare som lyssnar efter klick på Play/Pause knappen på remoten,
        // vi sätter action: "next", och target: self, vilket gör att den, när vi klickar på knappen
        // kommer leta reda på metoden next() på objectet self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "next")
        tapRecognizer.allowedPressTypes = [NSNumber(integer: UIPressType.PlayPause.rawValue)]
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(animated: Bool) {
        // När vyn har både laddats och visas ser vi till att anropa next(), vilket startar
        // upp en film på måfå
        next()
        
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // Det här är en enkel metod inbyggt i UIViewController som helt enkelt säger till
        // när du klickat ned och släpper upp på touchytan på din remote
        next()
    }
    
    private func nextIndex() -> Int {
        // Just nu slumpar vi bara vilket som är nästa video att spela, jag brukar förövrigt
        // aldrig skriva while(true), men nu hade jag bråttom :|
        while(true) {
            let randomIndex = Int(arc4random_uniform(UInt32(mediaFiles.count)))
            if(randomIndex != currentIndex) {
                return randomIndex
            }
        }
    }
    
    func next() {
        do {
            try playVideo()
        } catch {
            debugPrint("Generic error")
        }
    }
    
    private func playVideo() throws {
        // vi slumpar fram ett nytt index
        currentIndex = nextIndex()
        let mediaFile = mediaFiles[currentIndex]
        
        // Vi loggar vilken film det är vi tänker försöka oss på att spela
        debugPrint("Attempting to play: \(mediaFile)")
        
        // Vi behöver ha rätt på filändelsen för att kunna leta reda på filmen, så vi kör
        // en enkel split som returnerar en array
        var split = mediaFile.componentsSeparatedByString(".")
        if split.count != 2 {
            return
        }
        
        self.player?.pause()
        self.player = nil
        // Nu har vi grävt fram vilken fil vi ska spela, och delat upp den i namn + filändelse,
        // vilket är vad som krävs för att få en
        if let filePath = NSBundle.mainBundle().pathForResource(split[0], ofType: split[1]) {
            let player = AVPlayer(URL: NSURL(fileURLWithPath: filePath))
            self.player = player
            
            self.view.frame = self.view.frame
            player.play()
            
            // Vi sätter en lyssnare på detta videoklipp för att få en callback när den är färdigspelad,
            // i exemplet med UITapGestureRecognizer längre upp satte vi en action: "next",
            // i det här fallet skriver vi selector: "playerItemDidReachEnd:", skillnaden här är att
            // vi har kolon på slutet, med detta säger vi att vi vill att det ska skickas med mer 
            // information, i vårt fall ser denna metod ut såhär; 
            // playerItemDidReachEnd(notification: NSNotification)
            NSNotificationCenter.defaultCenter().addObserver(self,
                selector: "playerItemDidReachEnd:",
                name: AVPlayerItemDidPlayToEndTimeNotification,
                object: player.currentItem)
        }
    }
    
    func extractFiles() -> [String] {
        // Generella saker man gör för att hämta ut path till de filer som hör till vår app
        let fm = NSFileManager.defaultManager()
        let path = NSBundle.mainBundle().resourcePath!
        let items = try! fm.contentsOfDirectoryAtPath(path)
        var mediaPaths = [String]()
        
        // Sånt här går nog göra snyggare, men det här blir jy tydligt tycker jag 
        for item in items {
            if(item.lowercaseString.containsString(".mov")
                || item.lowercaseString.containsString("avi")) {
                mediaPaths.append(item)
            }
        }
        return mediaPaths
    }
    
    
    func playerItemDidReachEnd(notification: NSNotification) {
        next()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

