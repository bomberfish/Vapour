//
//  ContentView.swift
//  VapourTweakTool
//
//  Created by Hariz Shirazi on 2025-11-10.
//

import SwiftUI
import CoreFoundation

struct ContentView: View {
    let allApps = LSApplicationWorkspace.default().allApplications().filter({$0.isInstalled && !$0.isLaunchProhibited && !$0.bundleIdentifier.isEmpty}).removingDuplicates()
    @State var filteredApps: [LSApplicationProxy] = []
    @State private var selectedBundleID: String = ""
    @State var query = ""
    @State private var currentDomain: String = UserDefaults.globalDomain
    @State private var enabled: Bool = false
    @State private var opacity: Double = 1.0
    @State private var overrideColours: Bool = false
    @State private var debug: Bool = false
    @State private var isEnabledSet: Bool = false
    @State private var isOpacitySet: Bool = false
    @State private var isOverrideColoursSet: Bool = false
    @State private var isDebugSet: Bool = false
    var body: some View {
        HStack {
            List(selection: $selectedBundleID) {
                Text("Global")
                    .tag("")
                ForEach(filteredApps, id: \.bundleIdentifier) { app in
                    Text(app.bundleIdentifier)
                        .tag(app.bundleIdentifier)
                }
            }
            .frame(maxWidth: 250)
            .searchable(text: $query)
            VStack(alignment: .leading, spacing: 10) {
                Text(selectedBundleID.isEmpty ? "Global" : selectedBundleID)
                    .font(.headline)
                Toggle("Enabled", isOn: $enabled)
                    .onChange(of: enabled) {_ in
                        if currentDomain == UserDefaults.globalDomain {
                            CFPreferencesSetAppValue("VapourEnabled" as CFString, enabled as CFPropertyList?, kCFPreferencesAnyApplication)
                            CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
                        } else {
                            UserDefaults(suiteName: currentDomain)?.set(enabled, forKey: "VapourEnabled")
                        }
                    }
                VStack(alignment: .leading, spacing: 1) {
                    Text("Opacity: \(opacity, specifier: "%.2f")")
                    Slider(value: $opacity, in: 0...1)
                        .onChange(of: opacity) {_ in
                            if currentDomain == UserDefaults.globalDomain {
                                CFPreferencesSetAppValue("VapourOpacity" as CFString, opacity as CFPropertyList?, kCFPreferencesAnyApplication)
                                CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
                            } else {
                                UserDefaults(suiteName: currentDomain)?.set(opacity, forKey: "VapourOpacity")
                            }
                        }
                }
                Toggle("Override Colours", isOn: $overrideColours)
                    .onChange(of: overrideColours) {_ in
                        if currentDomain == UserDefaults.globalDomain {
                            CFPreferencesSetAppValue("VapourOverrideColours" as CFString, overrideColours as CFPropertyList?, kCFPreferencesAnyApplication)
                            CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
                        } else {
                            UserDefaults(suiteName: currentDomain)?.set(overrideColours, forKey: "VapourOverrideColours")
                        }
                    }
                Toggle("Debug", isOn: $debug)
                    .onChange(of: debug) {_ in
                        if currentDomain == UserDefaults.globalDomain {
                            CFPreferencesSetAppValue("VapourDebug" as CFString, debug as CFPropertyList?, kCFPreferencesAnyApplication)
                            CFPreferencesAppSynchronize(kCFPreferencesAnyApplication)
                        } else {
                            UserDefaults(suiteName: currentDomain)?.set(debug, forKey: "VapourDebug")
                        }
                    }
                Spacer()
                HStack {
                    Spacer()
                    Text("Note: Changes will only take effect after relaunching.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                    Spacer()
                }
            }
            .padding()
            .toggleStyle(.checkbox)
            .onAppear {
                filteredApps = allApps
                loadValues()
            }
            .onChange(of: query) {_ in
                if filteredApps.isEmpty { filteredApps = allApps; return }
                filteredApps = allApps.filter({$0.bundleIdentifier.localizedCaseInsensitiveContains(query)})
            }
            .onChange(of: selectedBundleID) {_ in
                currentDomain = selectedBundleID.isEmpty ? UserDefaults.globalDomain : selectedBundleID
                loadValues()
            }
        }
    }
    
    func loadValues() {
        if currentDomain == UserDefaults.globalDomain {
            enabled = (CFPreferencesCopyAppValue("VapourEnabled" as CFString, kCFPreferencesAnyApplication) as? Bool) ?? true
            opacity = (CFPreferencesCopyAppValue("VapourOpacity" as CFString, kCFPreferencesAnyApplication) as? Double) ?? 0.9
            overrideColours = (CFPreferencesCopyAppValue("VapourOverrideColours" as CFString, kCFPreferencesAnyApplication) as? Bool) ?? false
            debug = (CFPreferencesCopyAppValue("VapourDebug" as CFString, kCFPreferencesAnyApplication) as? Bool) ?? false
        } else {
            let defaults = UserDefaults.standard.persistentDomain(forName: currentDomain) ?? [:]
            enabled = defaults["VapourEnabled"] as? Bool ?? true
            opacity = defaults["VapourOpacity"] as? Double ?? 0.9
            overrideColours = defaults["VapourOverrideColours"] as? Bool ?? false
            debug = defaults["VapourDebug"] as? Bool ?? false
        }
    }
}

extension Array where Element: LSApplicationProxy {
    func removingDuplicates() -> [Element] {
        var seen = Set<String>()
        return self.filter { app in
            let id = app.bundleIdentifier
            if seen.contains(id) { return false }
            seen.insert(id)
            return true
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}

#Preview {
    ContentView()
}
