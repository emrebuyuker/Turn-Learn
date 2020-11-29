//
//  WordsResponseModel.swift
//  Turn Learn
//
//  Created by Emre BÜYÜKER on 29.11.2020.
//

import Foundation

struct WordsResponseModel: Codable {
    var firstWord: String
    var secondWord: String
    var documentId: String?
}
