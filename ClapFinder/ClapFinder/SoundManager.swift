//
//  SoundManager.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//

import Foundation
import AVFoundation
import AudioToolbox
import UIKit

class SoundManager: NSObject, ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    private var audioSession = AVAudioSession.sharedInstance()
    private var soundTimer: Timer?
    
    // Sistem sesleri için ID'ler
    private let systemSounds: [String: SystemSoundID] = [
        "Alarm": 1005,
        "Bell": 1013,
        "Chime": 1016,
        "Horn": 1009,
        "Siren": 1023
    ]
    
    override init() {
        super.init()
        print("🔊 SoundManager başlatıldı")
    }
    
    func startContinuousAlarm() {
        print("🚨 Sürekli alarm başlatılıyor")
        
        // Önceki sesi durdur
        stopSound()
        
        // Audio session'ı ses için ayarla
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.duckOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session sürekli alarm için ayarlandı")
        } catch {
            print("❌ Audio session hatası: \(error)")
        }
        
        // Sürekli ses çalmaya başla
        startInfiniteSound()
    }
    
    private func startInfiniteSound() {
        print("🔄 Sonsuz ses döngüsü başlatılıyor")
        
        soundTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
            print("📢 Alarm sesi çalınıyor")
            
            // Birden fazla ses birden çal - daha yüksek ses
            AudioServicesPlayAlertSound(1016)  // Chime
            AudioServicesPlayAlertSound(1007)  // Message
            AudioServicesPlayAlertSound(1013)  // Bell
            
            // Güçlü titreşim
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            // Haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
        
        // İlk sesi hemen çal
        print("📢 İlk alarm sesi")
        AudioServicesPlayAlertSound(1016)
        AudioServicesPlayAlertSound(1007)
        AudioServicesPlayAlertSound(1013)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    func stopSound() {
        print("🛑 Ses durduruldu")
        soundTimer?.invalidate()
        soundTimer = nil
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func testSound(_ soundName: String) {
        print("🧪 Test: \(soundName)")
        
        // Test için tek ses çal
        AudioServicesPlayAlertSound(1016)  // Chime
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    // Geriye uyumluluk için playSound fonksiyonu
    func playSound(_ soundName: String, repeat count: Int = 1) {
        print("🔊 Tek seferlik ses: \(soundName)")
        testSound(soundName)
    }
}

extension SoundManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer = nil
    }
}
