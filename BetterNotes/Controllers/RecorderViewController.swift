//
//  RecorderViewController.swift
//  BetterNotes
//
//  Created by Александр Бисеров on 18.02.2021.
//

import AVFoundation
import UIKit
import Firebase

class RecorderViewController: UIViewController{
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var paths = Array<URL>()
    var note = Note(headtitle: "", content: [], uniqueId: "", folderName: "")
    var ref: DatabaseReference!
    var client: Client!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self?.loadReadyToRecordingUI()
                    } else {
                        self?.loadFailedUI()
                    }
                }
            }
        } catch let error as NSError {
            loadFailedUI()
            print(error.localizedDescription)
        }
        
        view.addSubview(playButton)
        view.addSubview(recordButton)
        
        layout()
        
        guard let curentUser = Auth.auth().currentUser else { return }
        client = Client(user: curentUser)

    }
    
    func getURL() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print("Path: \(paths[0])")
        return paths[0]
    }
    
    func startRecording() {
        let audioFilename = getURL().appendingPathComponent("smth.m4a")
        paths.append(audioFilename)
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            loadRecordingUI()
        } catch let error as NSError{
            print(error.localizedDescription)
        }
    }
    
    func stopRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        let title = success ? "Tap to Re-record" : "Tap to record"
        
        recordButton.setTitle(title, for: .normal)
        view.backgroundColor = .green
    }
    
    private func startPlaying() {
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: paths[0], fileTypeHint: AVFileType.m4a.rawValue)
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                loadReadyToRecordingUI()
            } else {
                audioPlayer.play()
                loadPlayingUI()
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Setup UI
    let recordButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.backgroundColor = .blue
        button.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        return button
    }()
    
    @objc private func recordTapped() {
        (audioRecorder == nil) ? startRecording() : stopRecording(success: true)
    }
    
    let playButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Tap to play", for: .normal)
        button.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        
        return button
    }()
    
    @objc private func playTapped() {
        startPlaying()
    }
    
    private func loadPlayingUI() {
        view.backgroundColor = .blue
        playButton.setTitle("Tap tp pause", for: .normal)
    }
    
    private func layout() {
        recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        recordButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        playButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        playButton.leadingAnchor.constraint(equalTo: recordButton.trailingAnchor, constant: 10).isActive = true
    }
    
    private func loadReadyToRecordingUI() {
        view.backgroundColor = .green
        recordButton.setTitle("Tap to record", for: .normal)
    }
    
    private func loadRecordingUI() {
        view.backgroundColor = .red
        recordButton.setTitle("Tap to stop", for: .normal)
    }
    
    private func loadFailedUI() {
        view.backgroundColor = .gray
        recordButton.setTitle("", for: .normal)
    }
}

extension RecorderViewController: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            stopRecording(success: false)
        }
    }
}
