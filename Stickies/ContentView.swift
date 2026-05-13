//
//  ContentView.swift
//  Stickies
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var notes: [Note]
    @State private var selectedNote: Note?

    let columns = [GridItem(.adaptive(minimum: 160), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                if notes.isEmpty {
                    ContentUnavailableView(
                        "メモがありません",
                        systemImage: "note.text",
                        description: Text("+ボタンでメモを追加しましょう")
                    )
                    .padding(.top, 80)
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(notes) { note in
                            NoteCard(note: note)
                                .onTapGesture { selectedNote = note }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Stickies")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: addNote) {
                        Label("メモを追加", systemImage: "plus")
                    }
                }
            }
            .sheet(item: $selectedNote) { note in
                NoteEditorView(note: note)
            }
        }
    }

    private func addNote() {
        let note = Note()
        modelContext.insert(note)
        selectedNote = note
    }
}

struct NoteCard: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !note.title.isEmpty {
                Text(note.title)
                    .font(.headline)
                    .lineLimit(2)
            }
            Text(note.body.isEmpty ? "タップして編集" : note.body)
                .font(.body)
                .lineLimit(6)
                .foregroundStyle(note.body.isEmpty ? .secondary : .primary)
            Spacer()
        }
        .padding(12)
        .frame(minHeight: 120)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(note.color.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 2, y: 1)
    }
}

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let colorOptions: [(String, Color)] = [
        ("yellow", .yellow),
        ("orange", .orange),
        ("pink",   .pink),
        ("green",  .green),
        ("blue",   .blue),
        ("purple", .purple),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ForEach(colorOptions, id: \.0) { name, color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle().stroke(Color.primary.opacity(0.6), lineWidth: note.colorName == name ? 3 : 0)
                            )
                            .onTapGesture {
                                note.colorName = name
                                note.updatedAt = Date()
                            }
                    }
                    Spacer()
                }
                .padding()

                TextField("タイトル", text: $note.title)
                    .font(.title2.bold())
                    .padding(.horizontal)
                    .onChange(of: note.title) { _, _ in note.updatedAt = Date() }

                Divider().padding(.vertical, 8)

                TextEditor(text: $note.body)
                    .padding(.horizontal, 8)
                    .onChange(of: note.body) { _, _ in note.updatedAt = Date() }
            }
            .background(note.color.opacity(0.25).ignoresSafeArea())
            .navigationTitle("メモを編集")
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("削除", role: .destructive) {
                        modelContext.delete(note)
                        dismiss()
                    }
                    .foregroundStyle(.red)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
