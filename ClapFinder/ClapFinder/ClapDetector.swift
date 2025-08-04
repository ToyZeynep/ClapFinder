//
//  ClapDetector.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//

import Foundation
import AVFoundation
import Combine

class ClapDetector: NSObject, ObservableObject {
    @Published var clapDetected = false
    
    private var audioEngine = AVAudioEngine()
    private var audioSession = AVAudioSession.sharedInstance()
    
    // Alkış algılama parametreleri
    private var threshold: Float = 0.02  // Çok daha düşük threshold
    private var lastClapTime: Date = Date.distantPast
    private let cooldownPeriod: TimeInterval = 10.0  // 10 saniye cooldown - ses çalma bitene kadar
    private var debugCounter = 0
    
    override init() {
        super.init()
    }
    
    func updateSensitivity(_ newSensitivity: Double) {
        threshold = Float(newSensitivity)
    }
    
    func startListening() {
        print("🎤 Mikrofon dinleme başlatılıyor...")
        
        requestMicrophonePermission { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.setupAudio()
                }
            } else {
                print("❌ Mikrofon izni reddedildi")
            }
        }
    }
    
    private func setupAudio() {
        // Temizlik
        stopListening()
        
        do {
            // Basit audio session
            try audioSession.setCategory(.record)
            try audioSession.setActive(true)
            print("✅ Audio session hazır")
            
            // Input node
            let inputNode = audioEngine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            print("📊 Format: \(inputFormat)")
            
            // Tap kur
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputFormat) { [weak self] buffer, _ in
                self?.processAudio(buffer)
            }
            
            // Engine başlat
            try audioEngine.start()
            print("🚀 Audio engine başlatıldı")
            
        } catch {
            print("❌ Audio kurulum hatası: \(error)")
        }
    }
    
    func stopListening() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            print("⏹️ Dinleme durduruldu")
        }
    }
    
    private func processAudio(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData else { return }
        
        let frames = buffer.frameLength
        let samples = channelData[0]
        
        // RMS ve Peak hesapla
        var rms: Float = 0
        var peak: Float = 0
        
        for i in 0..<Int(frames) {
            let sample = samples[i]
            let absValue = abs(sample)
            rms += sample * sample
            if absValue > peak {
                peak = absValue
            }
        }
        rms = sqrt(rms / Float(frames))
        
        // Debug (her 20 buffer'da bir)
        debugCounter += 1
        if debugCounter % 20 == 0 {
            print("🔊 RMS: \(String(format: "%.3f", rms)), Peak: \(String(format: "%.3f", peak)), Threshold: \(threshold)")
        }
        
        // Alkış kontrolü - RMS veya Peak yüksekse
        let isLoudEnough = rms > threshold || peak > (threshold * 3)
        
        if isLoudEnough {
            let now = Date()
            let timeSinceLastClap = now.timeIntervalSince(lastClapTime)
            
            if timeSinceLastClap > cooldownPeriod {
                lastClapTime = now
                print("👏 ALKIŞ ALGILANDI! RMS: \(String(format: "%.3f", rms)), Peak: \(String(format: "%.3f", peak))")
                
                DispatchQueue.main.async {
                    self.clapDetected = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.clapDetected = false
                    }
                }
            } else {
                print("⏳ Cooldown aktif: \(String(format: "%.1f", timeSinceLastClap)) saniye")
            }
        }
    }
    
    private func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        switch audioSession.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        @unknown default:
            completion(false)
        }
    }
}
