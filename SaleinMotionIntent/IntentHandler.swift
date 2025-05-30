//
//  IntentHandler.swift
//  SaleinMotionIntent
//
//  Created by Abidcomputers on 12/05/2025.
//

import Intents

import FirebaseCore

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

class IntentHandler: INExtension {
    override init() {
            super.init()
        
        FirebaseApp.configure()
            
        }
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
            

            queryChatGPT(with: idea) { responseText in
                let idea = IdeasModel.init(idea: idea, response: responseText)
                
                self.saveIdeaToFirestore(idea) { error in
                    if error != nil {
                        let responseFa = SalesInMotionIntentResponse(code: .failure, userActivity: nil)
                        //responseFa.r = responseText
                        completion(responseFa)
                    }else{
                        let response = SalesInMotionIntentResponse(code: .success, userActivity: nil)
                        response.response = responseText
                        completion(response)
                    }
                }
                
            }

            
        }
    }
    
    
    func fetchAPIKey () async -> String {
       
        do {
            let document = try await Firestore.firestore().collection("Open_AI_Key").getDocuments()
            
            guard let data = document.documents.first?.data() else {
                return ""
            }
            
            let key = data["key"] as! String
            
            return key
        }
        catch let error {
            print("Error \(error)")
            
            return ""
        }
        
    }
    
    func getUniqueDeviceId() -> String {
        if let id = UIDevice.current.identifierForVendor?.uuidString {
            return id
        }
        return UUID().uuidString // fallback, but shouldn't happen
    }
    
    func saveIdeaToFirestore(_ idea: IdeasModel, completion: ((Error?) -> Void)? = nil) {
        let db = Firestore.firestore()
        
        let deviceId = getUniqueDeviceId()

        // Convert the idea to a dictionary
        do {
            let data = try idea.toDictionary()
            
            // Save to a "ideas" collection with an auto-generated document ID
            db.collection("devices")
                .document(deviceId).collection("ideas").addDocument(data: data) { error in
                if let error = error {
                    print("❌ Error saving idea to Firestore: \(error.localizedDescription)")
                } else {
                    print("✅ Idea saved to Firestore successfully.")
                }
                completion?(error)
            }
        } catch {
            print("❌ Failed to encode idea: \(error)")
            completion?(error)
        }
    }



    
    
    func resolveTitle(for intent: SalesInMotionIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let title = intent.title else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: title))
    }
    
    
    
    func queryChatGPT(with idea: String, completion: @escaping (String) -> Void) {
        
        Task {
            let apiKey = await fetchAPIKey()
            
            
            guard !apiKey.isEmpty else {
                completion("API key not found.")
                return
            }
            
            
            let url = URL(string: "https://api.openai.com/v1/chat/completions")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payload: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [
                    ["role": "system", "content": "You are a helpful idea coach. Reply to user ideas with encouragement and advice."],
                    ["role": "user", "content": idea]
                ],
                "max_tokens": 150
            ]
            
            request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    completion("Failed to get response")
                    return
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content)
                } else {
                    completion("No valid response from ChatGPT")
                }
            }.resume()
        }
    }

}


extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let dict = jsonObject as? [String: Any] else {
            throw NSError(domain: "Invalid JSON format", code: -1)
        }
        return dict
    }
}
