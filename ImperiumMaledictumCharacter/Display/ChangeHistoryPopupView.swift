//
//  ChangeHistoryPopupView.swift
//  ImperiumMaledictumCharacter
//
//  Created by User on 20.08.2025.
//

import SwiftUI

struct ChangeHistoryPopupView: View {
    @Binding var character: ImperiumCharacter
    var store: CharacterStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Session Controls
                VStack(spacing: 16) {
                    Text("Current Session")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            character.decrementSession()
                            store.saveChanges()
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(character.currentSession > 1 ? .red : .gray)
                        }
                        .disabled(character.currentSession <= 1)
                        
                        Text("\(character.currentSession)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(minWidth: 40)
                        
                        Button(action: {
                            character.incrementSession()
                            store.saveChanges()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                // Change History List
                if character.changeLog.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Changes Recorded")
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Changes to your character will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(groupedChangeLog(), id: \.session) { sessionGroup in
                                Section {
                                    ForEach(sessionGroup.entries) { entry in
                                        ChangeLogEntryRow(entry: entry)
                                    }
                                } header: {
                                    SessionHeader(session: sessionGroup.session)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Change History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // Group change log entries by session for display
    private func groupedChangeLog() -> [SessionGroup] {
        let grouped = Dictionary(grouping: character.changeLog) { $0.session }
        return grouped.map { SessionGroup(session: $0.key, entries: $0.value.sorted { $0.timestamp > $1.timestamp }) }
            .sorted { $0.session > $1.session } // Most recent session first
    }
}

struct SessionGroup {
    let session: Int
    let entries: [ChangeLogEntry]
}

struct SessionHeader: View {
    let session: Int
    
    var body: some View {
        HStack {
            Text("Session \(session)")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

struct ChangeLogEntryRow: View {
    let entry: ChangeLogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.summary)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(formatTimestamp(entry.timestamp))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
    
    private func formatTimestamp(_ timestamp: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

#Preview {
    let sampleCharacter = ImperiumCharacter()
    sampleCharacter.name = "Test Character"
    sampleCharacter.currentSession = 3
    sampleCharacter.changeLog = [
        ChangeLogEntry(summary: "Character created", session: 1),
        ChangeLogEntry(summary: "name Test→Test Character, weapon skill 25→30", session: 1),
        ChangeLogEntry(summary: "Session incremented to 2", session: 2),
        ChangeLogEntry(summary: "toughness 25→30, wounds 8→9", session: 2),
        ChangeLogEntry(summary: "Session incremented to 3", session: 3),
        ChangeLogEntry(summary: "talents changed", session: 3)
    ]
    
    return ChangeHistoryPopupView(
        character: .constant(sampleCharacter),
        store: CharacterStore()
    )
}