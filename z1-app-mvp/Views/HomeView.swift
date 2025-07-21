//
//  HomeView.swift
//  z1-app-mvp
//
//  Created by Amit Anand on 7/19/25.
//

import SwiftUI
import PhotosUI

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject private var viewModel: HomeViewModel
    @State private var selectedItem: PhotosPickerItem?
    
    init() {
        // Initialize with a temporary service container, will be replaced by environment object
        self._viewModel = StateObject(wrappedValue: HomeViewModel(serviceContainer: ServiceContainer()))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    headerView
                    
                    // Progress Indicator
                    progressIndicatorView
                    
                    // Content Area
                    contentArea
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            // Update viewModel with the actual service container from environment
            viewModel.updateServiceContainer(serviceContainer)
            
            // Initialize Secure Enclave if needed
            Task {
                await viewModel.initializeSecureEnclave()
            }
        }
        .photosPicker(isPresented: .constant(false), selection: $selectedItem, matching: .images)
        .onChange(of: selectedItem) { _, item in
            Task {
                await loadImage(from: item)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK") { }
        } message: {
            Text(viewModel.errorMessage ?? "An unknown error occurred")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("z-1")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            Text("Cryptographic Pipeline")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            // Secure Enclave Status
            HStack(spacing: 8) {
                Image(systemName: viewModel.isSecureEnclaveAvailable ? "lock.shield.fill" : "lock.shield")
                    .foregroundColor(viewModel.isSecureEnclaveAvailable ? .green : .gray)
                
                Text(viewModel.isSecureEnclaveAvailable ? "Secure Enclave Ready" : "Secure Enclave Unavailable")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(viewModel.isSecureEnclaveAvailable ? .green : .gray)
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicatorView: some View {
        HStack(spacing: 20) {
            ForEach(1...4, id: \.self) { step in
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(stepColor(for: step))
                            .frame(width: 50, height: 50)
                        
                        if step < viewModel.currentStep {
                            Image(systemName: "checkmark")
                                .foregroundColor(.black)
                                .font(.system(size: 20, weight: .bold))
                        } else {
                            Text("\(step)")
                                .foregroundColor(step <= viewModel.currentStep ? .black : .gray)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    
                    Text(stepTitle(for: step))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(step <= viewModel.currentStep ? .white : .gray)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        VStack(spacing: 20) {
            switch viewModel.currentStep {
            case 1:
                step1View
            case 2:
                step2View
            case 3:
                step3View
            case 4:
                step4View
            default:
                step1View
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Step Views
    private var step1View: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Select a Photo")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text("Choose an image from your photo library to begin the cryptographic pipeline")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                HStack {
                    Image(systemName: "photo")
                    Text("Select Photo")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
    
    private var step2View: some View {
        VStack(spacing: 20) {
            if let photoItem = viewModel.selectedPhoto {
                // Photo Preview
                AsyncImage(url: nil) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 200)
                            .cornerRadius(12)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(height: 200)
                    @unknown default:
                        EmptyView()
                    }
                }
                .task {
                    // Load image for preview
                    await loadImagePreview(from: photoItem)
                }
                
                Text("Generate Hash")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                // Show hashing progress if available
                if let progress = viewModel.hashingProgress {
                    Text(progress)
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    Task {
                        await viewModel.generateHash()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "function")
                        }
                        Text(viewModel.isLoading ? "Generating..." : "Generate Hash")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isLoading ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    private var step3View: some View {
        VStack(spacing: 20) {
            if let signatureData = viewModel.signatureData {
                // Hash Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hash (SHA-256)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(signatureData.hash)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: {
                            UIPasteboard.general.string = signatureData.hash
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .cornerRadius(8)
                
                Text("Sign Hash")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Button(action: {
                    Task {
                        await viewModel.signHash()
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "key")
                        }
                        Text(viewModel.isLoading ? "Signing..." : "Sign Hash")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isLoading ? Color.gray : Color.orange)
                    .cornerRadius(12)
                }
                .disabled(viewModel.isLoading)
            }
        }
    }
    
    private var step4View: some View {
        VStack(spacing: 20) {
            if let attestationData = viewModel.attestationData {
                // Transaction Hash Display
                VStack(alignment: .leading, spacing: 8) {
                    Text("Transaction Hash")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text(attestationData.transactionHash)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Spacer()
                        
                        Button(action: {
                            UIPasteboard.general.string = attestationData.transactionHash
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                .cornerRadius(8)
                
                Text("Attestation Complete!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Your photo has been successfully attested on-chain")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    viewModel.resetPipeline()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Start Over")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.purple)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func stepColor(for step: Int) -> Color {
        if step < viewModel.currentStep {
            return .green
        } else if step == viewModel.currentStep {
            return .blue
        } else {
            return Color(red: 0.2, green: 0.2, blue: 0.2)
        }
    }
    
    private func stepTitle(for step: Int) -> String {
        switch step {
        case 1: return "Select\nPhoto"
        case 2: return "Generate\nHash"
        case 3: return "Sign\nHash"
        case 4: return "Attest\nOn-Chain"
        default: return ""
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item = item else { return }
        
        // Directly select the PhotosPickerItem for real hashing
        viewModel.selectPhoto(item)
    }
    
    private func loadImagePreview(from item: PhotosPickerItem) async {
        // This function is for UI preview only, not for hashing
        // The actual hashing will be done in the RealHashingService
    }
}

#Preview {
    HomeView()
        .environmentObject(ServiceContainer())
} 