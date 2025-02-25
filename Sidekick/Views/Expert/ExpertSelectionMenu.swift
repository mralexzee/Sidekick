//
//  ExpertSelectionMenu.swift
//  Sidekick
//
//  Created by Bean John on 10/10/24.
//

import SwiftUI

struct ExpertSelectionMenu: View {
	
	@Environment(\.colorScheme) var colorScheme
	
	@EnvironmentObject private var expertManager: ExpertManager
	@EnvironmentObject private var conversationState: ConversationState
	
	var selectedExpert: Expert? {
		guard let selectedExpertId = conversationState.selectedExpertId else {
			return nil
		}
		return expertManager.getExpert(id: selectedExpertId)
	}
	
	var isInverted: Bool {
		guard let luminance = selectedExpert?.color.luminance else { return false }
		let forDark: Bool = (luminance > 0.5) && (colorScheme == .dark)
		let forLight: Bool = (luminance < 0.5) && (
			colorScheme == .light
		)
		return forDark || forLight
	}
	
	var inactiveExperts: [Expert] {
		return expertManager.experts.filter({ expert in
			expert != selectedExpert
		})
	}
	
	var createExpertTip: CreateExpertsTip = .init()
	
	var body: some View {
		Group {
			prevButton
			menu
				.popoverTip(
					createExpertTip,
					arrowEdge: .top
				) { action in
					// Open expert editor
					conversationState.isManagingExperts.toggle()
				}
			nextButton
		}
		.if(isInverted) { view in
			view.colorInvert()
		}
	}
	
	var prevButton: some View {
		Button {
			switchToPrevExpert()
		} label: {
			Label("Previous Expert", systemImage: "chevron.backward")
		}
		.keyboardShortcut("[", modifiers: [.command])
	}
	
	var nextButton: some View {
		Button {
			switchToNextExpert()
		} label: {
			Label("Next Expert", systemImage: "chevron.forward")
		}
		.keyboardShortcut("]", modifiers: [.command])
	}
	
	var menu: some View {
		Menu {
			Group {
				selectOptions
				if !inactiveExperts.isEmpty {
					Divider()
				}
				manageExpertsButton
			}
		} label: {
			label
		}
	}
	
	var selectOptions: some View {
		ForEach(
			inactiveExperts
		) { expert in
			Button {
				withAnimation(.linear) {
					conversationState.selectedExpertId = expert.id
				}
			} label: {
				expert.label
			}
		}
	}
	
	var manageExpertsButton: some View {
		Button {
			conversationState.isManagingExperts.toggle()
		} label: {
			Text("Manage Experts")
		}
		.onChange(of: conversationState.isManagingExperts) {
			// Show tip if needed
			if !conversationState.isManagingExperts &&
				LengthyTasksController.shared.hasTasks {
				LengthyTasksProgressTip.hasLengthyTask = true
			}
		}
	}
	
	var label: some View {
		Group {
			if selectedExpert == nil {
				Text("Select an Expert")
					.bold()
					.padding(7)
					.padding(.horizontal, 2)
					.background {
						RoundedRectangle(cornerRadius: 8)
							.fill(Color.white)
							.opacity(0.5)
					}
			} else {
				HStack {
					Image(systemName: self.selectedExpert!.symbolName)
					Text(self.selectedExpert!.name)
						.bold()
				}
			}
		}
	}
	
	/// Function to switch to the next expert
	private func switchToNextExpert() {
		let expertsIds: [UUID] = (expertManager.experts + expertManager.experts).map({ $0.id })
		guard let selectedExpertId = conversationState.selectedExpertId else {
			withAnimation(.linear) {
				self.conversationState.selectedExpertId = expertManager.firstExpert?.id
			}
			return
		}
		guard let index = expertsIds.firstIndex(of: selectedExpertId) else {
			return
		}
		withAnimation(.linear) {
			self.conversationState.selectedExpertId = expertsIds[index + 1]
		}
	}
	
	/// Function to switch to the last expert
	private func switchToPrevExpert() {
		let expertsIds: [UUID] = (expertManager.experts + expertManager.experts).map({ $0.id })
		guard let selectedExpertId = conversationState.selectedExpertId else {
			withAnimation(.linear) {
				self.conversationState.selectedExpertId = expertManager.lastExpert?.id
			}
			return
		}
		guard let index = expertsIds.lastIndex(of: selectedExpertId) else {
			return
		}
		withAnimation(.linear) {
			self.conversationState.selectedExpertId = expertsIds[index - 1]
		}
	}
	
}

//#Preview {
//    ExpertSelectionMenu()
//}
