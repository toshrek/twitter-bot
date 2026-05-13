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
#if os(macOS)
                    .frame(minWidth: 440, minHeight: 400)
#endif
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
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 6) {
                if !note.title.isEmpty {
                    Text(note.title)
                        .font(.headline)
                        .lineLimit(2)
                        .padding(.trailing, 28)
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

            #if os(macOS)
            Button {
                openWindow(id: "sticky-note", value: note.id)
            } label: {
                Image(systemName: "macwindow.on.rectangle")
                    .font(.caption)
                    .padding(5)
                    .background(.black.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .buttonStyle(.plain)
            .padding(7)
            .help("デスクトップに表示")
            #endif
        }
    }
}

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    let colorOptions: [(String, Color)] = [
        ("yellow", .yellow),
        ("orange", .orange),
        ("pink",   .pink),
        ("green",  .green),
        ("blue",   .blue),
        ("purple", .purple),
    ]

    let fontSizes: [(String, Double)] = [
        ("小", 12),
        ("中", 16),
        ("大", 20),
        ("特大", 24),
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
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)

                HStack {
                    Text("文字サイズ")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Picker("", selection: Binding(
                        get: { note.displayFontSize },
                        set: { note.fontSize = $0; note.updatedAt = Date() }
                    )) {
                        ForEach(fontSizes, id: \.1) { label, size in
                            Text(label).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                Divider()

                TextField("タイトル", text: $note.title)
                    .font(.system(size: note.displayFontSize + 4, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .onChange(of: note.title) { _, _ in note.updatedAt = Date() }

                Divider().padding(.vertical, 8)

                TextEditor(text: $note.body)
                    .font(.system(size: note.displayFontSize))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
#if os(macOS)
                ToolbarItem {
                    Button {
                        openWindow(id: "sticky-note", value: note.id)
                        dismiss()
                    } label: {
                        Label("デスクトップに表示", systemImage: "macwindow.on.rectangle")
                    }
                }
#endif
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
