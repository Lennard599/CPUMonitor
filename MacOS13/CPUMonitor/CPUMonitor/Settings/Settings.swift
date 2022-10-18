//
//  Settings.swift
//  SettingsSwitfUI
//
//  Created by Lennard on 02.10.22.
//

import SwiftUI
import Combine


struct Settings: View {
    @EnvironmentObject private var configHandler :ConfigHandler
    @State private var error = false
    
    func validatePositiveInt(_ string: String) -> Int? {
        if let num = Int(string) {
            if num > 0 {
                return num
            }
        }
        return nil
    }
    
    func validatePositiveFloat(_ string: String) -> Float? {
        if let num = Float(string) {
            if num > 0 {
                return num
            }
        }
        return nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if error {
            Text("Please enter a positive number")
                    .foregroundColor(.red)
            }
            HStack {
                Text("Refresh intervall:")
                    .padding(.trailing, 14)
                ValidatedTextField(content: $configHandler.conf.refreshIntervall, error: $error, validate: validatePositiveFloat(_:), onFocusLost: {configHandler.submit.toggle()})
                    .frame(width: 100)
                Text("seconds")
            }
            HStack {
                Text("Detailed memory view:")
                    .padding(.trailing, 35)
                Toggle(isOn: $configHandler.conf.detailedMemory) {
                    
                }
                .toggleStyle(CheckboxToggleStyle())
            }
            HStack {
                Text("Start at login:")
                    .padding(.trailing, 35)
                Toggle(isOn: $configHandler.conf.atLogin) {
                    
                }
                .toggleStyle(CheckboxToggleStyle())
            }
        }.onDisappear {
            configHandler.submit.toggle()
        }
        .padding(.leading, -95.0)
    }


}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
            .environmentObject(ConfigHandler())
            .frame(width: 450, height: 150)
    }
}
