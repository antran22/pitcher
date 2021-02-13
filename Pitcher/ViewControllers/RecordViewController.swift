//
//  RecordViewController.swift
//  Pitcher
//
//  Created by Tran Cong Viet An on 09/02/2021.
//
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!

    var audioRecorder: AVAudioRecorder!

    let stopImage: UIImage! = UIImage(named: "Stop")
    let recordImage: UIImage! = UIImage(named: "Record")

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recordButton.setImage(stopImage, for: .selected)
        recordButton.setImage(recordImage, for: .normal)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))

        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
    }

    @IBAction func didPressedRecordButton(_ sender: Any) {
        recordButton.isSelected = !recordButton.isSelected
        if (recordButton.isSelected) {
            didStartRecording()
        } else {
            didStopRecording()
        }
    }

    func didStartRecording() {
        recordLabel.text = "Recording right now..."
        recordLabel.sizeToFit()

        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    func didStopRecording() {
        recordLabel.text = "Tap to record"
        recordLabel.sizeToFit()

        audioRecorder.stop()
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(false)
    }

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            showAlert(title: "Recording failed", message: "Unabled to record audio")
            return
        }
        performSegue(withIdentifier: "playSounds", sender: recorder.url)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "playSounds" {
            let targetViewController = segue.destination as! PlaySoundViewController
            let url = sender as! URL
            targetViewController.recordedAudioURL = url
        }
    }
}
