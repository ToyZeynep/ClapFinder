//
//  ContentView.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//

import SwiftUI
import UIKit
import AudioToolbox

struct ContentView: View {
    @StateObject private var clapDetector = ClapDetector()
    @StateObject private var soundManager = SoundManager()
    @StateObject private var flashManager = FlashManager()
    @StateObject private var settings = SettingsManager()
    @State private var isListening = false
    @State private var isAlarmActive = false  // Alarm aktif mi?
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo ve Başlık
                VStack(spacing: 15) {
                    Image(systemName: "hands.clap.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("ClapFinder")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Alkış çalarak telefonunu bul!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 50)
                
                Spacer()
                
                // Durum Göstergesi
                VStack(spacing: 20) {
                    Circle()
                        .fill(getStatusColor())
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: getStatusIcon())
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(shouldAnimate() ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: shouldAnimate())
                    
                    Text(getStatusText())
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(getStatusColor())
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // Ana Buton
                Button(action: {
                    toggleMode()
                }) {
                    Text(getButtonText())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(getButtonColor())
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showingSettings = true
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                }
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings, soundManager: soundManager, flashManager: flashManager)
        }
        .onReceive(clapDetector.$clapDetected) { detected in
            if detected && isListening && !isAlarmActive {
                triggerAlarm()
            }
        }
        .onAppear {
            clapDetector.updateSensitivity(settings.sensitivity)
        }
        .onChange(of: settings.sensitivity) { newSensitivity in
            clapDetector.updateSensitivity(newSensitivity)
        }
    }
    
    private func toggleMode() {
        if isAlarmActive {
            // Alarm aktifse - durdur
            stopAlarm()
        } else if isListening {
            // Dinleme aktifse - durdur
            stopListening()
        } else {
            // Kapalıysa - dinlemeye başla
            startListening()
        }
    }
    
    private func startListening() {
        isListening = true
        isAlarmActive = false
        clapDetector.startListening()
        print("🎤 Alkış dinleme başlatıldı")
    }
    
    private func stopListening() {
        isListening = false
        clapDetector.stopListening()
        print("⏹️ Alkış dinleme durduruldu")
    }
    
    private func stopAlarm() {
        isAlarmActive = false
        isListening = false
        soundManager.stopSound()
        flashManager.stopFlashing()
        print("🚨 Alarm durduruldu")
    }
    
    private func triggerAlarm() {
        print("🚨 ALKIŞ ALGILANDI! Alarm başlatılıyor...")
        
        // Mikrofonu durdur
        clapDetector.stopListening()
        isListening = false
        isAlarmActive = true
        
        // Kısa bekleme sonra alarm başlat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            // Sürekli ses başlat
            self.soundManager.startContinuousAlarm()
            
            // Flaş başlat
            if self.settings.flashEnabled {
                self.flashManager.startContinuousFlashing()
            }
            
            // İlk titreşim
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
    
    // UI Helper fonksiyonları
    private func getStatusColor() -> Color {
        if isAlarmActive {
            return .red
        } else if isListening {
            return .green
        } else {
            return .gray
        }
    }
    
    private func getStatusIcon() -> String {
        if isAlarmActive {
            return "speaker.wave.3.fill"
        } else if isListening {
            return "ear"
        } else {
            return "power"
        }
    }
    
    private func getStatusText() -> String {
        if isAlarmActive {
            return "Alarm Çalıyor!\nTelefonunuzu Bulun"
        } else if isListening {
            return "Alkış Dinleniyor..."
        } else {
            return "Hazır"
        }
    }
    
    private func getButtonText() -> String {
        if isAlarmActive {
            return "Alarmı Durdur"
        } else if isListening {
            return "Dinlemeyi Durdur"
        } else {
            return "Başla"
        }
    }
    
    private func getButtonColor() -> Color {
        if isAlarmActive {
            return .red
        } else if isListening {
            return .orange
        } else {
            return .blue
        }
    }
    
    private func shouldAnimate() -> Bool {
        return isListening || isAlarmActive
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
