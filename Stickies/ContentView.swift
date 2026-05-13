//
//  ContentView.swift
//  Stickies
//

import SwiftUI
import SwiftData
import WidgetKit

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
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct NoteCard: View {
    let note: Note
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 6) {
                if !note.displayTitle.isEmpty {
                    Text(note.displayTitle)
                        .font(.headline)
                        .lineLimit(2)
                        .padding(.trailing, 28)
                }
                Text(note.displayBody.isEmpty ? "タップして編集" : note.displayBody)
                    .font(.body)
                    .lineLimit(6)
                    .foregroundStyle(note.displayBody.isEmpty ? .secondary : .primary)
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
                if let id = note.id { openWindow(id: "sticky-note", value: id) }
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
        #if os(macOS)
        .contextMenu {
            Button("デスクトップに表示") {
                if let id = note.id { openWindow(id: "sticky-note", value: id) }
            }
        }
        #endif
    }
}

struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    let colorOptions: [(String, Color)] = [
        ("yellow", .yellow), ("orange", .orange), ("pink", .pink),
        ("green", .green), ("blue", .blue), ("purple", .purple),
    ]
    let fontSizes: [(String, Double)] = [
        ("小", 12), ("中", 16), ("大", 20), ("特大", 24),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ForEach(colorOptions, id: \.0) { name, color in
                        Circle()
                            .fill(color)
                            .frame(width: 30, height: 30)
                            .overlay(Circle().stroke(Color.primary.opacity(0.6),
                                lineWidth: note.colorName == name ? 3 : 0))
                            .onTapGesture { note.colorName = name; note.updatedAt = Date() }
                    }
                    Spacer()
                }
                .padding(.horizontal).padding(.top, 12).padding(.bottom, 8)

                HStack {
                    Text("文字サイズ").font(.caption).foregroundStyle(.secondary)
                    Picker("", selection: Binding(
                        get: { note.displayFontSize },
                        set: { note.fontSize = $0; note.updatedAt = Date() }
                    )) {
                        ForEach(fontSizes, id: \.1) { Text($0.0).tag($0.1) }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal).padding(.bottom, 10)

                Divider()

                TextField("タイトル", text: Binding(
                    get: { note.displayTitle },
                    set: { note.title = $0; note.updatedAt = Date() }
                ))
                .font(.system(size: note.displayFontSize + 4, weight: .bold))
                .padding(.horizontal).padding(.top, 8)

                Divider().padding(.vertical, 8)

                TextEditor(text: Binding(
                    get: { note.displayBody },
                    set: { note.body = $0; note.updatedAt = Date() }
                ))
                .font(.system(size: note.displayFontSize))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 8)
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
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    }.foregroundStyle(.red)
                }
#if os(macOS)
                ToolbarItem {
                    Button {
                        if let id = note.id { openWindow(id: "sticky-note", value: id); dismiss() }
                    } label: {
                        Label("デスクトップに表示", systemImage: "macwindow.on.rectangle")
                    }
                }
#endif
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        WidgetCenter.shared.reloadAllTimelines()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
