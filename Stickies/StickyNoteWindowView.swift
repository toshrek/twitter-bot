#if os(macOS)
//
//  StickyNoteWindowView.swift
//  Stickies
//

import SwiftUI
import SwiftData
import AppKit

struct StickyNoteWindowView: View {
    let noteID: UUID
    @Query private var notes: [Note]

    var note: Note? { notes.first { $0.id == noteID } }

    var body: some View {
        if let note {
            StickyNoteEditor(note: note)
        }
    }
}

private struct StickyNoteEditor: View {
    @Bindable var note: Note

    var body: some View {
        ZStack {
            note.color.opacity(0.88).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 4) {
                TextField("タイトル", text: $note.title)
                    .font(.system(size: note.displayFontSize + 4, weight: .bold))
                    .textFieldStyle(.plain)
                    .onChange(of: note.title) { _, _ in note.updatedAt = Date() }

                Divider().opacity(0.4)

                TextEditor(text: $note.body)
                    .font(.system(size: note.displayFontSize))
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .onChange(of: note.body) { _, _ in note.updatedAt = Date() }
            }
            .padding()
        }
        .background(FloatingWindowConfigurer())
    }
}

private struct FloatingWindowConfigurer: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.level = .floating
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
        }
        return view
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
