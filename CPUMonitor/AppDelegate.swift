//
//  AppDelegate.swift
//  CPUMonitor
//
//  Created by Lennard Kittner on 21.08.18.
//  Copyright © 2018 Lennard Kittner. All rights reserved.
//

import Cocoa
//import LaunchAtLogin
import SystemKit

struct State {
    let memory_max = System.physicalMemory()
    let defaultConfig =
                """
                Memdetail: no
                AtLogin: no
                Refresh: 0.5
                """
        .data(using: String.Encoding.utf8, allowLossyConversion: false)!
    var startAtLogin = false
    var detailedMemory = false
    var refreshTime :Double = 0.5
    var oldUsage :Double = 0.0
    var icons = [NSImage]()
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var state = State()
    var timer :Timer?
    var sys :System?
    var preferencesController :NSWindowController?
    // /Users/<name>/Library/Containers/com.Lennard.CPUMonitor/Data/Library/"Application Support"/CPUMonitor/
    let conf_dir = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/")
    let conf_file = URL(fileURLWithPath: "\(FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].path)/CPUMonitor/CPUMonitor.cfg")
    
    //TODO make it more generic
    func readCfg() -> State {
        var state = State()
        
        try! FileManager.default.createDirectory(atPath: conf_dir.path, withIntermediateDirectories: true, attributes: nil)
        if !FileManager.default.fileExists(atPath: (conf_file.path)) {
            FileManager.default.createFile(atPath: (conf_file.path), contents: state.defaultConfig, attributes: nil)
        }
        else {
            let conf = try!  String.init(contentsOf: conf_file).components(separatedBy: CharacterSet.newlines)
            for c in conf {
                if c.contains("Memdetail:") {
                    if c.contains("yes") {
                        state.detailedMemory = true
                    }
                }
                else if c.contains("AtLogin:") {
                    if c.contains("yes") {
                        state.startAtLogin = true
                        setStartAtLogin()
                    }
                }
                else if c.contains("Refresh:") {
                    state.refreshTime = Double(c.components(separatedBy: ":")[1]) ?? 0.5
                }
            }
        }
        return state
    }
    
    func loadImages() {
        for i in stride(from: 0, to: 101, by: 2) {
            state.icons.append(NSImage(named: NSImage.Name(String(i)))!)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        state = readCfg()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
        sys = System()
        loadImages()
        
        statusItem.length = 60
        statusItem.menu = NSMenu()
        statusItem.menu?.delegate = self
        initMenu(menu: statusItem.menu!)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func setStartAtLogin() {
        //LaunchAtLogin.isEnabled = startAtLogin
    }
    
    @objc func startTimer(wait: Double){
        timer = Timer.scheduledTimer(timeInterval: wait, target: self, selector: #selector(refresh(_:)), userInfo: nil, repeats: true)
    }

    @objc func refresh(_ sender: Any?) {
        let cpuUsage = sys?.usageCPU()
        let usaged = (cpuUsage?.user)!+(cpuUsage?.system)!
        if state.oldUsage != usaged && usaged > 0 {
            statusItem.button?.toolTip = "CPUusage: \(String(format: "%.2f",usaged))%"
            refreshIcon(usage: usaged)
        }
    }
    
    func refreshIcon(usage: Double){
        let index = Int(usage / 2)
        statusItem.button?.image = state.icons[index]
    }
    
    func refreshMenu(menu: NSMenu) {
        let memoryUsage = System.memoryUsage()
        let memoryUsageA  = [memoryUsage.free, memoryUsage.inactive, memoryUsage.compressed, memoryUsage.active, memoryUsage.wired]
        (menu.item(at: 0) as? SimpleMemItem)?.update(val1: memoryUsage.free + memoryUsage.inactive, val2: state.memory_max)
        
        if state.detailedMemory {
            for i in 1..<menu.items.count {
                (menu.item(at: 0) as? SimpleMemItem)?.update(val1: memoryUsageA[i])
            }
        }
    }
    
    func initMenu(menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(createSimpleMemItem())
        
        if state.detailedMemory {
            createDetailedMemItems().map({menu.addItem($0)})
        }
    
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(AppDelegate.showPreferences(_:)), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }
    
    func createSimpleMemItem() -> NSMenuItem {
        return SimpleMemItem(prefix: "Memory: ", middle: " GB / ", suffix: " GB", toolTip: "memory usage (free + inactive)")
    }
    
    func createDetailedMemItems() -> [NSMenuItem] {
        var items :[NSMenuItem] = []
        items.append(SimpleMemItem(prefix: "Free: ", suffix: " GB", toolTip: "free memory"))
        items.append(SimpleMemItem(prefix: "Inactive: ", suffix: " GB", toolTip: "memory used by closed apps to speed up next launch"))
        items.append(SimpleMemItem(prefix: "Compressed: ", suffix: " GB", toolTip: "compresed memory"))
        items.append(SimpleMemItem(prefix: "Active: ", suffix: " GB", toolTip: "activly used user memory "))
        items.append(SimpleMemItem(prefix: "Wired: ", suffix: " GB", toolTip: "system memory"))
        return items
    }

    @objc func showPreferences(_ sender: Any?) {
        if (preferencesController == nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if (preferencesController != nil) {
            preferencesController!.showWindow(sender)
        }
    }
}
