//
//  Translation.swift
//  LocalizationEditor
//
//  Created by Sascha Müllner on 27.01.22.
//  Copyright © 2022 Igor Kulman. All rights reserved.
//

import Foundation

struct Translated: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let detectedSourceLanguage: String
    let text: String

    enum CodingKeys: String, CodingKey {
        case detectedSourceLanguage = "detected_source_language"
        case text
    }
}
