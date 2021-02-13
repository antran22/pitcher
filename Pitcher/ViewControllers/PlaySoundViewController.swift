//
//  PlaySoundViewController.swift
//  Pitcher
//
//  Created by Tran Cong Viet An on 12/02/2021.
//

import UIKit
import AVFoundation

class PlaySoundViewController: UIViewController {
    @IBOutlet weak var slowButton: UIButton!
    @IBOutlet weak var fastButton: UIButton!
    @IBOutlet weak var lowButton: UIButton!
    @IBOutlet weak var highButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!

    private enum SoundEffect: Int {
        case slow = 0,
            fast,
            low,
            high,
            reverb,
            echo
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            recordedAudioFile = try AVAudioFile(forReading: recordedAudioURL)
        } catch {
            showAlert(title: "Playback failed", message: error.localizedDescription)
        }
    }

    var recordedAudioURL: URL!
    private var recordedAudioFile: AVAudioFile!
    private var audioEngine: AVAudioEngine!
    private var audioPlayer: AVAudioPlayerNode!
    private var stopTimer: Timer!

    private func playSound(rate: Float = 1.0, pitch: Float = 0, echo: Bool = false, reverb: Bool = false) {

        (audioEngine, audioPlayer) = prepareAudioEngine(rate: rate, pitch: pitch, echo: echo, reverb: reverb, audioFile: recordedAudioFile)

        audioPlayer.stop()
        audioPlayer.scheduleFile(recordedAudioFile, at: nil) {
            var delayInSeconds: Double = 0
            if let lastRenderTime = self.audioPlayer.lastRenderTime,
                let playerTime = self.audioPlayer.playerTime(forNodeTime: lastRenderTime) {
                delayInSeconds = Double(self.recordedAudioFile.length - playerTime.sampleTime) /
                Double(self.recordedAudioFile.processingFormat.sampleRate) /
                Double(rate)
            }

            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(self.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer, forMode: .default)
        }

        do {
            try audioEngine.start()
        } catch {
            showAlert(title: "Playback error", message: error.localizedDescription)
        }
        audioPlayer.play()
    }

    private func setButtonUI(playing: Bool) {
        pauseButton.isEnabled = playing
        for button in [slowButton, fastButton, lowButton, highButton, reverbButton, echoButton] {
            button?.isEnabled = !playing
        }
    }

    @IBAction func playSoundForButton(_ sender: UIButton!) {
        if let effect = SoundEffect.init(rawValue: sender.tag) {
            setButtonUI(playing: true)
            switch effect {
            case .slow:
                playSound(rate: 0.5)
            case .fast:
                playSound(rate: 2)
            case .low:
                playSound(pitch: -1000)
            case .high:
                playSound(pitch: 1000)
            case .echo:
                playSound(echo: true)
            case .reverb:
                playSound(reverb: true)
            }
        }
    }

    @IBAction func stopPlaying(_ sender: UIButton!) {
        stopAudio()
    }

    @objc func stopAudio() {
        audioPlayer.stop()
        stopTimer?.invalidate()
        setButtonUI(playing: false)
        if let audioEngine = self.audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }

}
