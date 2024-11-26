//
//  AttachmentSelectionButton.swift
//  Sidekick
//
//  Created by Bean John on 11/26/24.
//

import FSKit_macOS
import SwiftUI

struct AttachmentSelectionButton: View {
	
	@EnvironmentObject private var promptController: PromptController
	
    var body: some View {
		Button {
			guard let selectedUrls: [URL] = try? FileManager.selectFile(
				dialogTitle: String(localized: "Select a File"),
				canSelectDirectories: false,
				allowMultipleSelection: true
			) else { return }
			Task.detached { @MainActor in
				for url in selectedUrls {
					await self.promptController.addFile(url)
				}
			}
		} label: {
			Label("Add Files", systemImage: "paperclip")
				.labelStyle(.iconOnly)
				.foregroundStyle(.secondary)
		}
		.buttonStyle(.plain)
		.padding(.leading, 10)
    }
	
}
