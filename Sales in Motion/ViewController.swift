//
//  ViewController.swift
//  Sales in Motion
//
//  Created by Abidcomputers on 12/05/2025.
//

import UIKit
import Intents
import IntentsUI

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, INUIAddVoiceShortcutViewControllerDelegate {
    
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: (any Error)?) {
        print(voiceShortcut?.invocationPhrase)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ideas.isEmpty ? 0  : ideas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell", for: indexPath) as! UITableViewCell
        
        
        cell.textLabel?.text = ideas[indexPath.item]
        
        return cell

    }
    
    @IBAction func addSiri(_ sender: Any) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    var ideas = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "IdeaCell")
        tableView.delegate = self
        tableView.dataSource = self
      
        let userDefaults = UserDefaults(suiteName: "group.com.genetum.xrun.Sales-in-Motion")
        ideas = userDefaults?.stringArray(forKey: "savedIdeas") ?? []
        
        print(ideas)
        
        tableView.reloadData()
    }


    
    @IBAction func addShortCut(_ sender: Any) {
        
        let intent = SalesInMotionIntent()
        //intent.title = "Demo"
        //intent.price = 0
        intent.suggestedInvocationPhrase = "Add New Idea"
        
        if let shortcut = INShortcut(intent: intent) {
            let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            viewController.delegate = self
            present(viewController, animated: true, completion: nil)
        } else {
            print("Failed to create shortcut")
        }
    }
    
    
}

