//
//  ViewController.swift
//  Sales in Motion
//
//  Created by Abidcomputers on 12/05/2025.
//

import UIKit
import Intents
import IntentsUI

import FirebaseFirestore

let sss = """
Adolf Hitler (1889–1945) was the dictator of Nazi Germany and one of history’s most infamous figures. He was born in Austria and rose to power as the leader of the National Socialist German Workers' Party (Nazi Party).

He became Chancellor of Germany in 1933 and later assumed full control as Führer (Leader) in 1934. Under his totalitarian regime, Hitler initiated policies that led to:

World War II (1939–1945): Starting with Germany's invasion of Poland.

The Holocaust: The systematic genocide of six million Jews and millions of others, including Roma people, disabled individuals, and political opponents.

Aggressive military expansion across Europe.

Extreme nationalism, racism, and anti-Semitism.

Hitler believed in the superiority of the so-called “Aryan” race and aimed to establish a German empire. His rule caused massive destruction and loss of life. As Allied forces closed in on Berlin in 1945, Hitler

"""

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "IdeaCell", for: indexPath) as! IdeasTableViewCell
        
        if !ideas.isEmpty {
            cell.ideaLabel.text = ideas[indexPath.row].idea
            cell.responseView.text = ideas[indexPath.row].response
        }
        
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
                
                // Remove from data source
                self.ideas.remove(at: indexPath.row)
                
                // Save the updated array to shared UserDefaults
                if let userDefaults = UserDefaults(suiteName: "group.com.genetum.xrun.Sales-in-Motion"),
                   let encoded = try? JSONEncoder().encode(self.ideas) {
                    userDefaults.set(encoded, forKey: "savedIdeas")
                }
                
                // Delete the row from the table view
                tableView.deleteRows(at: [indexPath], with: .automatic)
                
                // Call completion handler
                completionHandler(true)
            }
            
        return UISwipeActionsConfiguration(actions: [deleteAction])
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    
    @IBAction func addSiri(_ sender: Any) {
    }
    
    @IBOutlet weak var tableView: UITableView!
    var ideas = [IdeasModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
       
       
        tableView.delegate = self
        tableView.dataSource = self

        
        loadIdeasFromFirestore { [weak self] ide in
            guard let `self` = self else {
                return
            }
            
            self.ideas = ide
            self.tableView.reloadData()
        }
        
        
    }

    


    
    func getUniqueDeviceId() -> String {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            return id
        }
        return UUID().uuidString // fallback, but shouldn't happen
    }


    func loadIdeasFromFirestore(completion: @escaping ([IdeasModel]) -> Void) {
        let db = Firestore.firestore()
        let deviceId = getUniqueDeviceId()
        
        db.collection("devices")
            .document(deviceId).collection("ideas").getDocuments { snapshot, error in
            if let error = error {
                print("❌ Error fetching ideas: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            let ideas: [IdeasModel] = documents.compactMap { doc in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data())
                    let idea = try JSONDecoder().decode(IdeasModel.self, from: jsonData)
                    return idea
                } catch {
                    print("⚠️ Failed to decode idea: \(error)")
                    return nil
                }
            }

            completion(ideas)
        }
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

