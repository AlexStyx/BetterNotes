//
//  PlayerView.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 19.03.2021.
//

import Foundation
import UIKit
import AVFoundation

@IBDesignable
class PlayerView: UIView {
    
    var url = URL(string: "")
    var audioSession: AVAudioSession!
    var audioPlayer: AVAudioPlayer!
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        
    }
    
    @IBOutlet weak var timer: UILabel!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        startPlaying()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureView()
    }
    
    convenience init(url: URL) {
        self.init()
        configureView()
        configurePath(url: url)
    }
    
    private func configureView() {
        guard let view = self.loadViewFromNib(nibName: "PlayerView") else { return }
        view.frame = self.bounds
        view.layer.cornerRadius = 20
        self.addSubview(view)
        
        audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func startPlaying() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!, fileTypeHint: AVFileType.m4a.rawValue)
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.play()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    private func configurePath(url: URL){
        self.url = url
    }
    
}
