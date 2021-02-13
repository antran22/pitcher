//
//  Audio.swift
//  Pitcher
//
//  Created by Tran Cong Viet An on 13/02/2021.
//

import AVFoundation

func prepareAudioEngine(rate: Float = 1.0, pitch: Float = 0, echo: Bool = false, reverb: Bool = false, audioFile: AVAudioFile) -> (engine: AVAudioEngine, player: AVAudioPlayerNode) {
    let audioEngine = AVAudioEngine()
    let audioPlayerNode = AVAudioPlayerNode()
    var audioNodes: [AVAudioNode] = [audioPlayerNode]

    let changeRatePitchNode = AVAudioUnitTimePitch()
    changeRatePitchNode.pitch = pitch
    changeRatePitchNode.rate = rate
    audioNodes.append(changeRatePitchNode)

    if echo {
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioNodes.append(echoNode)
    }

    if reverb {
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.plate)
        reverbNode.wetDryMix = 50
        audioNodes.append(reverbNode)
    }

    for node in audioNodes {
        audioEngine.attach(node)
    }
    audioNodes.append(audioEngine.outputNode)
    for i in 0..<audioNodes.count - 1 {
        audioEngine.connect(audioNodes[i], to: audioNodes[i + 1], format: audioFile.processingFormat)
    }

    return (audioEngine, audioPlayerNode)
}
