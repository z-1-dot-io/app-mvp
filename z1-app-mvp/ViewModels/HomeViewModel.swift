//
//  HomeViewModel.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import Foundation
import Combine
import SwiftUI
import PhotosUI

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentStep: Int = 1
    @Published var selectedPhoto: PhotosPickerItem?
    @Published var photoData: PhotoData?
    @Published var signatureData: SignatureData?
    @Published var attestationData: AttestationData?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var hashingProgress: String?
    
    // MARK: - Private Properties
    private let serviceContainer: ServiceContainer
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var isSecureEnclaveAvailable: Bool {
        serviceContainer.secureEnclaveManager.isSecureEnclaveAvailable
    }
    
    var hasSecureEnclaveKeypair: Bool {
        serviceContainer.secureEnclaveManager.hasKeypair
    }
    
    var canProceedToStep2: Bool {
        selectedPhoto != nil
    }
    
    var canProceedToStep3: Bool {
        signatureData != nil
    }
    
    var canProceedToStep4: Bool {
        signatureData != nil
    }
    
    var isPipelineComplete: Bool {
        attestationData != nil
    }
    
    // MARK: - Initialization
    init(serviceContainer: ServiceContainer) {
        self.serviceContainer = serviceContainer
    }
    
    func updateServiceContainer(_ newContainer: ServiceContainer) {
        // This method allows updating the service container after initialization
        // This is needed because the environment object isn't available during init
    }
    
    /// Initialize Secure Enclave keypair if needed
    func initializeSecureEnclave() async {
        guard isSecureEnclaveAvailable && !hasSecureEnclaveKeypair else { return }
        
        isLoading = true
        clearError()
        
        do {
            _ = try await serviceContainer.secureEnclaveManager.generateKeypair()
        } catch {
            showError(message: "Failed to initialize Secure Enclave: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Public Methods
    func selectPhoto(_ photoItem: PhotosPickerItem) {
        selectedPhoto = photoItem
        currentStep = 2
        clearError()
    }
    
    func generateHash() async {
        guard let photoItem = selectedPhoto else { return }
        
        isLoading = true
        hashingProgress = "Extracting photo data..."
        clearError()
        
        do {
            // Generate real hash from photo
            let hash = try await serviceContainer.hashingService.hash(photo: photoItem)
            
            hashingProgress = "Signing with Secure Enclave..."
            
            // Sign the hash with Secure Enclave
            let signatureResult = try await serviceContainer.signatureService.sign(hash: hash)
            
            signatureData = SignatureData(
                hash: hash,
                signature: signatureResult.signature,
                publicKey: signatureResult.publicKey
            )
            
            hashingProgress = nil
            currentStep = 3
        } catch {
            hashingProgress = nil
            showError(message: "Failed to generate hash: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func signHash() async {
        guard let signatureData = signatureData else { return }
        
        isLoading = true
        clearError()
        
        do {
            let transactionHash = try await serviceContainer.attestationService.attest(
                hash: signatureData.hash,
                signature: signatureData.signature,
                publicKey: signatureData.publicKey
            )
            
            attestationData = AttestationData(
                hash: signatureData.hash,
                signature: signatureData.signature,
                publicKey: signatureData.publicKey,
                transactionHash: transactionHash
            )
            
            currentStep = 4
        } catch {
            showError(message: "Failed to sign hash: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func attestOnChain() async {
        // This step is already completed in signHash() for the MVP
        // In Phase 2, this would be a separate on-chain operation
        currentStep = 4
    }
    
    func resetPipeline() {
        selectedPhoto = nil
        photoData = nil
        signatureData = nil
        attestationData = nil
        currentStep = 1
        hashingProgress = nil
        clearError()
    }
    
    // MARK: - Private Methods
    private func clearError() {
        errorMessage = nil
        showError = false
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
} 