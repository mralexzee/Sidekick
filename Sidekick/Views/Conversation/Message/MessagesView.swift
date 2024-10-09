//
//  MessagesView.swift
//  Sidekick
//
//  Created by Bean John on 10/8/24.
//

import SwiftUI

struct MessagesView: View {
	
	@EnvironmentObject private var model: Model
	@EnvironmentObject private var conversationManager: ConversationManager
	@EnvironmentObject private var profileManager: ProfileManager
	
	@Namespace var scrollViewId
	
	@State private var prevPendingMessage: String = ""
	
	@Binding var selectedConversationId: UUID?
	
	var selectedConversation: Conversation? {
		guard let selectedConversationId else { return nil }
		return self.conversationManager.getConversation(
			id: selectedConversationId
		)
	}
	
	var messages: [Message] {
		return self.selectedConversation?.messages ?? []
	}
	
	var showPendingMessage: Bool {
		let statusPass: Bool = self.model.status == .coldProcessing || self.model.status == .processing
		let conversationPass: Bool = self.selectedConversation?.id == self.model.sentConversationId
		return statusPass && conversationPass
	}
	
	var body: some View {
		ScrollViewReader { proxy in
			ScrollView {
				HStack(alignment: .top) {
					LazyVStack(
						alignment: .leading,
						spacing: 13
					) {
						ForEach(self.messages) { message in
							MessageView(
								message: message
							)
						}
						if showPendingMessage {
							PendingMessageView()
						}
					}
					.padding(.vertical)
					.padding(.bottom, 55)
					.id(scrollViewId)
					Spacer()
				}
			}
			.onReceive(self.model.$pendingMessage) { _ in
				self.scrollOnUpdate(proxy: proxy)
			}
			.onReceive(self.model.$sentConversationId) { _ in
				proxy.scrollTo(scrollViewId, anchor: .bottom)
			}
			.onChange(of: self.selectedConversationId) {
				proxy.scrollTo(scrollViewId, anchor: .top)
			}
		}
	}
	
	/// Function to scroll to bottom when the output refreshes
	private func scrollOnUpdate(proxy: ScrollViewProxy) {
		let lines: Int = self.model.pendingMessage.split(
			separator: "\n"
		).count
		let prevLines: Int = self.prevPendingMessage.split(
			separator: "\n"
		).count
		// Exit if equal
		if prevLines >= lines {
			prevPendingMessage = ""
			return
		} else if abs(prevLines - lines) >= 2 {
			// Else, scroll to bottom if significant change
			proxy.scrollTo(scrollViewId, anchor: .bottom)
			prevPendingMessage = self.model.pendingMessage
		}
	}
	
}

//#Preview {
//    MessagesView()
//}
