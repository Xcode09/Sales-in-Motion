//
//  IdeasModel.swift
//  Sales in Motion
//
//  Created by Abidcomputers on 21/05/2025.
//

import Foundation

struct IdeasModel:Codable{
    var id = UUID().uuidString
    let idea:String
    let response:String
}
