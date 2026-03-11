//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel
    
    var body: some View {
        NavigationStack {
            List {
                avatarNameSection
                avatarAttributesSection
                avatarImageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .screenAppearAnalytics(name: "CreateAvatarView")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
        }
    }
    
    // MARK: - Views
    private var avatarNameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    
    private var avatarAttributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $viewModel.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { location in
                    Text(location.rawValue.capitalized)
                        .tag(location)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }
    }
    
    private var avatarImageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton {
                            viewModel.onGenerateImagePressed()
                        }
                        .opacity(!viewModel.isGeneratingImage ? 1 : 0)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGeneratingImage ? 1 : 0)
                }
                .disabled(viewModel.isGeneratingImage || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    }
                    .clipShape(Circle())
            }
            .removeListRowFormatting()
            .padding()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "Save",
                action: {
                    viewModel.onSavePressed(onDismiss: { dismiss() })
                }
            )
            .removeListRowFormatting()
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
            .disabled(viewModel.generatedImage == nil)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .fontWeight(.semibold)
            .foregroundStyle(.accent)
            .anyButton {
                viewModel.onBackPressed(onDismiss: { dismiss() })
            }
    }
}

#Preview {
    CreateAvatarView(viewModel: CreateAvatarViewModel(interactor: CoreInteractor(container: DevPreview.shared.container)))
        .previewEnvironment()
}
