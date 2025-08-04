//
//  SettingsView.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var settings: SettingsManager
    let soundManager: SoundManager
    let flashManager: FlashManager
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ses Ayarları")) {
                    Picker("Ses Seçimi", selection: $settings.selectedSound) {
                        ForEach(settings.availableSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    HStack {
                        Text("Tekrar Sayısı")
                        Spacer()
                        Stepper(value: $settings.soundRepeatCount, in: 1...10) {
                            Text("\(settings.soundRepeatCount)")
                        }
                    }
                    
                    Button("Sesi Test Et") {
                        testSound()
                    }
                    .foregroundColor(.blue)
                }
                
                Section(header: Text("Flaş Ayarları")) {
                    Toggle("Flaş Kullan", isOn: $settings.flashEnabled)
                    
                    if settings.flashEnabled {
                        HStack {
                            Text("Süre (saniye)")
                            Spacer()
                            Stepper(value: $settings.flashDuration, in: 5...30, step: 5) {
                                Text("\(Int(settings.flashDuration))")
                            }
                        }
                        
                        Button("Flaşı Test Et") {
                            testFlash()
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Algılama Hassasiyeti")) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Düşük")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Yüksek")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $settings.sensitivity, in: 0.005...0.1, step: 0.005)
                            .accentColor(.blue)
                        
                        Text("Mevcut Hassasiyet: \(Int(settings.sensitivity * 1000))/10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                
                Section(header: Text("Hakkında")) {
                    HStack {
                        Image(systemName: "hands.clap.fill")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text("ClapFinder")
                                .font(.headline)
                            Text("Versiyon 1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    
                    Text("Alkış çalarak telefonunuzu kolayca bulun!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Tamam") {
                    dismiss()
                }
            )
        }
    }
    
    private func testSound() {
        soundManager.testSound(settings.selectedSound)
    }
    
    private func testFlash() {
        flashManager.testFlash()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            settings: SettingsManager(),
            soundManager: SoundManager(),
            flashManager: FlashManager()
        )
    }
}
