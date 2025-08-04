//
//  SettingsManager.swift
//  ClapFinder
//
//  Created by Zeynep Toy on 3.08.2025.
//


import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var selectedSound: String {
        didSet {
            UserDefaults.standard.set(selectedSound, forKey: "selectedSound")
        }
    }
    
    @Published var flashEnabled: Bool {
        didSet {
            UserDefaults.standard.set(flashEnabled, forKey: "flashEnabled")
        }
    }
    
    @Published var sensitivity: Double {
        didSet {
            UserDefaults.standard.set(sensitivity, forKey: "sensitivity")
        }
    }
    
    @Published var soundRepeatCount: Int {
        didSet {
            UserDefaults.standard.set(soundRepeatCount, forKey: "soundRepeatCount")
        }
    }
    
    @Published var flashDuration: Double {
        didSet {
            UserDefaults.standard.set(flashDuration, forKey: "flashDuration")
        }
    }
    
    let availableSounds = ["Alarm", "Bell", "Chime", "Horn", "Siren"]
    
    init() {
        // UserDefaults'tan ayarları yükle
        self.selectedSound = UserDefaults.standard.string(forKey: "selectedSound") ?? "Alarm"
        self.flashEnabled = UserDefaults.standard.object(forKey: "flashEnabled") as? Bool ?? true
        self.sensitivity = UserDefaults.standard.object(forKey: "sensitivity") as? Double ?? 0.02
        self.soundRepeatCount = UserDefaults.standard.object(forKey: "soundRepeatCount") as? Int ?? 5
        self.flashDuration = UserDefaults.standard.object(forKey: "flashDuration") as? Double ?? 10.0
    }
    
    func resetToDefaults() {
        selectedSound = "Alarm"
        flashEnabled = true
        sensitivity = 0.02
        soundRepeatCount = 5
        flashDuration = 10.0
    }
}
