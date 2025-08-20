//
//  ChangeLogEntry.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 20.08.2025.
//

import Foundation

struct ChangeLogEntry: Codable, Identifiable, Equatable {
    let id = UUID()
    let summary: String
    let timestamp: Date
    let session: Int
    
    init(summary: String, session: Int = 1) {
        self.summary = summary
        self.timestamp = Date()
        self.session = session
    }
    
    enum CodingKeys: String, CodingKey {
        case id, summary, timestamp, session
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        summary = try container.decode(String.self, forKey: .summary)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        session = try container.decodeIfPresent(Int.self, forKey: .session) ?? 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(summary, forKey: .summary)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(session, forKey: .session)
    }
    
    static func == (lhs: ChangeLogEntry, rhs: ChangeLogEntry) -> Bool {
        lhs.id == rhs.id
    }
}