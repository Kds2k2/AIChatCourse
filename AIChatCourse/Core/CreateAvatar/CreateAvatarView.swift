//
//  CreateAvatarView.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 04.01.2026.
//

import SwiftUI

struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(AIManager.self) private var aiManager
    @Environment(AuthManager.self) private var authManager
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    
    @State private var avatarName: String = ""
    @State private var characterOption: CharacterOption = .default
    @State private var characterAction: CharacterAction = .default
    @State private var characterLocation: CharacterLocation = .default
    
    @State private var showAlert: AnyAppAlert?
    @State private var isGeneratingImage: Bool = false
    @State private var generatedImage: UIImage?
    
    @State private var isSaving: Bool = false
    
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
            .showCustomAlert(alert: $showAlert)
        }
    }
    
    // MARK: - Views
    private var avatarNameSection: some View {
        Section {
            TextField("Player 1", text: $avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    
    private var avatarAttributesSection: some View {
        Section {
            Picker(selection: $characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }
            
            Picker(selection: $characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { action in
                    Text(action.rawValue.capitalized)
                        .tag(action)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $characterLocation) {
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
                            onGenerateImagePressed()
                        }
                        .opacity(!isGeneratingImage ? 1 : 0)
                    
                    ProgressView()
                        .tint(.accent)
                        .opacity(isGeneratingImage ? 1 : 0)
                }
                .disabled(isGeneratingImage || avatarName.isEmpty)
                
                Circle()
                    .fill(.secondary.opacity(0.3))
                    .overlay {
                        ZStack {
                            if let generatedImage {
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
                isLoading: isSaving,
                title: "Save",
                action: onSavePressed
            )
            .removeListRowFormatting()
            .opacity(generatedImage == nil ? 0.5 : 1.0)
            .disabled(generatedImage == nil)
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .fontWeight(.semibold)
            .foregroundStyle(.accent)
            .anyButton {
                onBackPressed()
            }
    }
    
    // MARK: - Actions
    private func onBackPressed() {
        dismiss()
        logManager.trackEvent(event: Event.backButtonPressed)
    }
    
    private func onGenerateImagePressed() {
        isGeneratingImage = true
        logManager.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let promt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await aiManager.generateImage(input: promt)
                logManager.trackEvent(event: Event.generateImageSuccess(description: avatarDescriptionBuilder))
            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGeneratingImage = false
        }
    }
    
    private func onSavePressed() {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage = generatedImage else { return }
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let userId = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: userId
                )
                
                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                dismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    // MARK: - Logs
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart, generateImageSuccess(description: AvatarDescriptionBuilder), generateImageFail(error: Error)
        case saveAvatarStart, saveAvatarSuccess(avatar: AvatarModel), saveAvatarFail(error: Error)
        
        static var screenName: String = "CreateAvatarView"
        
        var eventName: String {
            switch self {
            case .backButtonPressed:            return "\(Event.screenName)_BackButton_Pressed"
            case .generateImageStart:           return "\(Event.screenName)_GenerateImage_Start"
            case .generateImageSuccess:         return "\(Event.screenName)_GenerateImage_Success"
            case .generateImageFail:            return "\(Event.screenName)_GenerateImage_Fail"
            case .saveAvatarStart:              return "\(Event.screenName)_SaveAvatar_Start"
            case .saveAvatarSuccess:            return "\(Event.screenName)_SaveAvatar_Success"
            case .saveAvatarFail:               return "\(Event.screenName)_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .saveAvatarFail(error: let error), .generateImageFail(error: let error):
                return error.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageSuccess(description: let description):
                return description.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                    .severe
            case .saveAvatarFail:
                    .waring
            default:
                    .analytic
            }
        }
    }
}

#Preview {
    CreateAvatarView()
        .environment(AIManager(service: MockAIService()))
        .environment(AuthManager(service: MockAuthService(user: .mock(isAnonymous: false))))
        .environment(AvatarManager(remote: MockAvatarService()))
}
