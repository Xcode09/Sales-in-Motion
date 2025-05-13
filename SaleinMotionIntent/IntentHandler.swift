//
//  IntentHandler.swift
//  SaleinMotionIntent
//
//  Created by Abidcomputers on 12/05/2025.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        guard intent is SalesInMotionIntent else {
            fatalError("Unhandled Intent error : \(intent)")
        }
        return SalesIntentHandler()
    }
    
}

class SalesIntentHandler:NSObject, SalesInMotionIntentHandling {
    func handle(intent: SalesInMotionIntent, completion: @escaping (SalesInMotionIntentResponse) -> Void) {
        if let idea = intent.title {
            print("Your idea \(idea)")
            
            saveIdeaToSharedDefaults(idea)
            
//            queryChatGPT(with: idea) { responseText in
//                
//                print("Your response \(responseText)")
//                let response = SalesInMotionIntentResponse(code: .success, userActivity: nil)
//                response.response = responseText
//                completion(response)
//            }
            
            let response = SalesInMotionIntentResponse(code: .success, userActivity: nil)
            response.response = "Logged: \(idea)"
            completion(response)
            
            
        }
    }
    
    
    func saveIdeaToSharedDefaults(_ idea: String) {
        let userDefaults = UserDefaults(suiteName: "group.com.genetum.xrun.Sales-in-Motion")
        var existingIdeas = userDefaults?.stringArray(forKey: "savedIdeas") ?? []
        existingIdeas.append(idea)
        userDefaults?.set(existingIdeas, forKey: "savedIdeas")
    }

    
    
    func resolveTitle(for intent: SalesInMotionIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let title = intent.title else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: title))
    }
    
    
    
    func queryChatGPT(with idea: String, completion: @escaping (String) -> Void) {

    }

}
