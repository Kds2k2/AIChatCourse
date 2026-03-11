//
//  CreateAvatarViewModel.swift
//  AIChatCourse
//
//  Created by Dmitro Kryzhanovsky on 10.03.2026.
//

import SwiftUI

@MainActor
protocol CreateAvatarInteractor {
    func trackEvent(event: LoggableEvent)
    func generateImage(input: String) async throws -> UIImage
    func getAuthId() throws -> String
    func createAvatar(avatar: AvatarModel,image: UIImage) async throws
}

extension CoreInteractor: CreateAvatarInteractor { }

@Observable
@MainActor
class CreateAvatarViewModel {
    let interactor: CreateAvatarInteractor

    var avatarName: String = ""
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var showAlert: AnyAppAlert?
    
    private(set) var isGeneratingImage: Bool = false
    private(set) var generatedImage: UIImage?
    private(set) var isSaving: Bool = false
    
    init(interactor: CreateAvatarInteractor) {
        self.interactor = interactor
    }
    
    // MARK: - Actions
    func onBackPressed(onDismiss: () -> Void) {
        onDismiss()
        interactor.trackEvent(event: Event.backButtonPressed)
    }
    
    func onGenerateImagePressed() {
        isGeneratingImage = true
        interactor.trackEvent(event: Event.generateImageStart)
        
        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let promt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await interactor.generateImage(input: promt)
                interactor.trackEvent(event: Event.generateImageSuccess(description: avatarDescriptionBuilder))
            } catch {
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGeneratingImage = false
        }
    }
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage = generatedImage else { return }
        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName)
                let userId = try interactor.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: userId
                )
                
                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))
                
                onDismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
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
