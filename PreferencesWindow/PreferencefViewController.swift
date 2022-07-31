//
//  PreferencefViewController.swift
//  ClipBoardManager
//
//  Created by Lennard Kittner on 18.08.18.
//  Copyright © 2018 Lennard Kittner. All rights reserved.
//

import Cocoa

class PreferencefViewController: NSTabViewController {
    
    @IBOutlet weak var gitHub: NSButtonCell!
    @IBOutlet weak var atLogin: NSButton!
    @IBOutlet weak var memdetail: NSButton!
    @IBOutlet weak var refresh: NSTextField!
    
    var appDelegate :AppDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        appDelegate = (NSApplication.shared.delegate as! AppDelegate)
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        if gitHub != nil {
            let blue = NSColor.linkColor
            let attributedStringColor = [NSAttributedStringKey.foregroundColor : blue];
            let title = NSAttributedString(string: "My GitHub", attributes: attributedStringColor)
            
            gitHub.attributedTitle = title
        }
        if atLogin != nil {
            atLogin.state = NSControl.StateValue(rawValue: (appDelegate?.startAtLogin)! ? 1 : 0)
            memdetail.state = NSControl.StateValue(rawValue: (appDelegate?.detailedMemory)! ? 1 : 0)
            refresh.stringValue = String(appDelegate?.refreshTime ?? 0.5)
        }
        //update Title
        self.parent?.view.window?.title = self.title!
    }
    
    func writeConf() {
        let conf_txt = """
        memdetail:\((appDelegate?.detailedMemory)! ? "yes" : "no")
        AtLogin:\((appDelegate?.startAtLogin)! ? "yes" : "no")
        Refresh:\(String((appDelegate?.refreshTime)!))
        """
        try! conf_txt.write(to: (appDelegate?.conf_file)!, atomically: true, encoding: String.Encoding.utf8)
    }
    
    @IBAction func autoStart(_ sender: NSButton) {
        appDelegate?.startAtLogin = !((appDelegate?.startAtLogin)!)
        appDelegate?.setStartAtLogin()
        writeConf()
    }
    
    @IBAction func memorydetail(_ sender: Any) {
        appDelegate?.detailedMemory = !((appDelegate?.detailedMemory)!)
        writeConf()
    }
    
    @IBAction func refreshChange(_ sender: NSTextField) {
        if sender.doubleValue > 0.0 {
            appDelegate?.refreshTime = Double(sender.doubleValue)
            appDelegate?.timer?.invalidate()
            appDelegate?.startTimer(wait: appDelegate?.refreshTime ?? 0.5)
            writeConf()
        }
    }
    
    @IBAction func openGitHub(_ sender: Any) {
        let url = URL(string: "https://github.com/Lennard599")!
        NSWorkspace.shared.open(url)
    }
}
