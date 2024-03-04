//
//  CreatorShowsViewModel.swift
//  MVVM Project
//
//  Created by Sergiu Corbu on 28.12.2022.
//

import Foundation

class CreatorShowsViewModel: ProfileComponents.ShowsGridViewModel {
    
    func insertShow(_ show: Show, at index: Int) {
        guard accessLevel == .readWrite else { return }
        shows.insert(show, at: index)
    }
    
    func removeShow(showID: String) {
        guard accessLevel == .readWrite, let showIndex = getShowIndex(id: showID) else {
            return
        }
        shows.remove(at: showIndex)
    }
    
    @MainActor
    @discardableResult
    func updateShow(showID: String) async throws -> Show? {
        guard accessLevel == .readWrite,
              let uploadedShow = try await showService.getCreatorShow(id: showID),
              let showIndex = getShowIndex(id: showID) else {
            return nil
        }
        
        shows[showIndex] = uploadedShow
        presentShowStatusChangedToast(for: uploadedShow.status)
        
        return uploadedShow
    }
    
    func updateCurrentProcessingShowStatus(id: String, status: ShowStatus) {
        guard let processingShowIndex = getShowIndex(id: id) else {
            return
        }
        
        if [ShowStatus.compressingVideo, .convertingVideo, .uploadingVideo].contains(status) {
            shows[processingShowIndex].status = status
        }
    }
    
    func updateShow(_ updatedShow: Show) {
        guard let showIndex = getShowIndex(id: updatedShow.id) else {
            return
        }
        shows[showIndex] = updatedShow
    }
    
    func presentShowStatusChangedToast(for showStatus: ShowStatus) {
        switch showStatus {
        case .published:
            ToastDisplay.showSuccessToast(message: Strings.ContentCreation.showUploaded)
        case .scheduled:
            ToastDisplay.showSuccessToast(message: Strings.ContentCreation.scheduledShowUploaded)
        default: break
        }
    }
    
    private func getShowIndex(id: String) -> Int? {
        return shows.firstIndex(where: { $0.id == id })
    }
}
