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
        ZStack(alignment: .topLeading) {
            if let note {
                note.color.opacity(0.9).ignoresSafeArea()
                VStack(alignment: .leading, spacing: 6) {
                    if !note.title.isEmpty {
                        Text(note.title)
                            .font(.system(size: note.displayFontSize + 4, weight: .bold))
                    }
                    Text(note.body)
                        .font(.system(size: note.displayFontSize))
                    Spacer()
                }
                .padding()
            }
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
