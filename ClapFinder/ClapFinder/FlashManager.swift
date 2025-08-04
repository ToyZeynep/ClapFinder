//
//  FlashManager.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//

import Foundation
import AVFoundation
import UIKit

class FlashManager: ObservableObject {
    private var captureDevice: AVCaptureDevice?
    private var flashTimer: Timer?
    
    init() {
        setupCaptureDevice()
    }
    
    private func setupCaptureDevice() {
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch else {
            print("Flaş desteklenmiyor")
            return
        }
        captureDevice = device
    }
    
    func startContinuousFlashing() {
        print("🔦 Sürekli flaş başlatılıyor")
        guard let device = captureDevice else {
            print("Flaş cihazı bulunamadı")
            return
        }
        
        stopFlashing() // Önce mevcut flaş durdur
        
        // Sonsuz yanıp sönme
        flashTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            do {
                try device.lockForConfiguration()
                
                // Flaş durumunu değiştir
                if device.torchMode == .off {
                    if device.isTorchModeSupported(.on) {
                        try device.setTorchModeOn(level: 1.0)
                    }
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
                
            } catch {
                print("Sürekli flaş kontrolü hatası: \(error)")
            }
        }
        
        print("🔦 Sürekli flaş başlatıldı")
    }
    
    // Geriye uyumluluk için eski startFlashing fonksiyonu
    func startFlashing(duration: TimeInterval = 10.0) {
        print("🔦 Belirli süre flaş: \(duration) saniye")
        
        // Sürekli flaşı başlat
        startContinuousFlashing()
        
        // Belirtilen süre sonra durdur
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.stopFlashing()
        }
    }
    
    func stopFlashing() {
        flashTimer?.invalidate()
        flashTimer = nil
        
        guard let device = captureDevice else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
        } catch {
            print("Flaş kapatma hatası: \(error)")
        }
    }
    
    func testFlash() {
        startFlashing(duration: 2.0) // 2 saniye test
    }
    
    deinit {
        stopFlashing()
    }
}
