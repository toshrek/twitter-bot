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
                TextField("タイトル", text: Binding(
                    get: { note.displayTitle },
                    set: { note.title = $0; note.updatedAt = Date() }
                ))
                .font(.system(size: note.displayFontSize + 4, weight: .bold))
                .textFieldStyle(.plain)

                Divider().opacity(0.4)

                TextEditor(text: Binding(
                    get: { note.displayBody },
                    set: { note.body = $0; note.updatedAt = Date() }
                ))
                .font(.system(size: note.displayFontSize))
                .scrollContentBackground(.hidden)
                .background(.clear)
            }
            .padding()
        }
        .background(WindowLevelManager())
    }
}

private struct WindowLevelManager: NSViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            guard let window = view.window else { return }
            window.titlebarAppearsTransparent = true
            window.styleMask.insert(.fullSizeContentView)
            window.level = .floating
            window.delegate = context.coordinator
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}

    class Coordinator: NSObject, NSWindowDelegate {
        func windowDidBecomeKey(_ notification: Notification) {
            (notification.object as? NSWindow)?.level = .floating
        }
        func windowDidResignKey(_ notification: Notification) {
            (notification.object as? NSWindow)?.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
        }
    }
}
#endif
