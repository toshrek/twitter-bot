//
//  Note.swift
//  Stickies
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Note {
    var id: UUID
    var title: String
    var body: String
    var colorName: String
    var fontSize: Double
    var createdAt: Date
    var updatedAt: Date

    init(title: String = "", body: String = "", colorName: String = "yellow", fontSize: Double = 16) {
        self.id = UUID()
        self.title = title
        self.body = body
        self.colorName = colorName
        self.fontSize = fontSize
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    var color: Color {
        switch colorName {
        case "orange": return .orange
        case "pink":   return .pink
        case "green":  return .green
        case "blue":   return .blue
        case "purple": return .purple
        default:       return .yellow
        }
    }
}
