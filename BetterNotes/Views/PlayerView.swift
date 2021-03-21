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
    var timer = Timer()
    var count = 0
    var isCounting = false
    
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func sliderMoved(_ sender: UISlider) {
        
    }
    
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if isCounting {
            sender.setTitle("Pause", for: .normal)
        } else {
            sender.setTitle("Play", for: .normal)
        }
        startStopPlaying()
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
        configurePath(url: url)
        configureView()
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
        slider.minimumValue = 0
        slider.value = 0
    }
    
    private func startStopPlaying() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url!, fileTypeHint: AVFileType.m4a.rawValue)
            let duration = Float(audioPlayer.duration.rounded())
            slider.maximumValue = duration
            print("duration is \(duration)")
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        } else {
            audioPlayer.play()
        }
        if isCounting {
            isCounting = false
            timer.invalidate()
            slider.value = 0
        } else {
            isCounting = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countTimer), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func countTimer() {
        count += 1
        slider.value = Float(count)
        timerLabel.text = "0.0\(count)"
        if count == Int(audioPlayer.duration.rounded()) {
            count = 0
//            slider.value = 0
            timer.invalidate()
        }
    }
    
    private func configurePath(url: URL){
        self.url = url
    }
}
