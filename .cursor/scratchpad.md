# z-1 MVP Development Plan

## Background and Motivation

The z-1 MVP is a single-codebase iOS application that demonstrates a complete cryptographic pipeline flow:
1. Photo selection from device gallery
2. Hash generation (SHA-256 dummy)
3. Hash signing via Secure Enclave (dummy)
4. On-chain attestation (dummy transaction)

**Key Goals:**
- 100% SwiftUI implementation
- End-to-end dummy flow completion rate ≥95%
- Crash-free sessions ≥99%
- Foundation for Phase 2 backend integration

**Target:** iOS 16+, devices with Secure Enclave (A11+)

## Key Challenges and Analysis

### Technical Architecture Challenges
1. **Protocol-based service abstraction** - Need to design services that can be easily swapped from dummy to real implementations
2. **Dependency injection** - Implement clean DI pattern for service management
3. **Async/await patterns** - Ensure all service calls are async-ready for future network integration
4. **State management** - Complex 4-step flow with progress tracking and error handling

### HEIC Format Implementation Challenges
1. **PHPicker filtering limitations** - PHPicker doesn't natively support format-based filtering
2. **HEIC format detection** - Need to implement proper HEIC file type validation
3. **User experience** - Must provide clear feedback when non-HEIC files are attempted
4. **Fallback handling** - What happens when no HEIC photos are available in the library

### Secure Enclave Implementation Challenges
1. **Device compatibility** - Secure Enclave only available on A11+ devices (iPhone 8+)
2. **Keypair persistence** - Need secure storage mechanism for public key reference
3. **Biometric authentication** - May require Touch ID/Face ID for key access
4. **Error handling** - Graceful degradation when Secure Enclave unavailable
5. **Key generation timing** - One-time generation on first app launch
6. **Cryptographic operations** - Real signing vs dummy implementation transition

### UI/UX Challenges
1. **Dark theme crypto aesthetic** - Modern, minimal design
2. **Progress indicator** - Visual step tracking (1-4)
3. **Copy functionality** - Hash, signature, and transaction hash copying
4. **Error handling** - Graceful degradation for missing permissions or Secure Enclave

### Performance Requirements
- Dummy pipeline completion <800ms
- Bundle size ≤18MB
- Launch screen ≤1.5s

## High-level Task Breakdown

### Phase 1: Project Foundation & Architecture
- [ ] **Task 1.1**: Set up MVVM architecture with Combine
  - Success Criteria: Basic app structure with ViewModels and service protocols defined
- [ ] **Task 1.2**: Create service protocols and dummy implementations
  - Success Criteria: HashingService, SignatureService, AttestationService protocols with dummy implementations
- [ ] **Task 1.3**: Implement dependency injection container
  - Success Criteria: ServiceContainer class that can inject services into views

### Phase 2: Core UI Components
- [x] **Task 2.1**: Design and implement Launch Screen
  - Success Criteria: App logo display with ≤1.5s duration
- [x] **Task 2.2**: Create HomeView with step progress indicator
  - Success Criteria: 4-step progress tracker with dark theme crypto aesthetic
- [x] **Task 2.3**: Implement photo picker and preview functionality
  - Success Criteria: PHPicker integration with live image preview

### Phase 2.5: HEIC Format Implementation (NEW)
- [ ] **Task 2.4**: Implement HEIC format validation and filtering
  - Success Criteria: Only HEIC photos can be selected, clear error messages for non-HEIC files
- [ ] **Task 2.5**: Add HEIC format detection and validation logic
  - Success Criteria: Proper HEIC file type checking with fallback handling
- [ ] **Task 2.6**: Update UI to indicate HEIC-only requirement
  - Success Criteria: Clear messaging about HEIC format requirement in the UI

### Phase 3: Secure Enclave Implementation (NEW)
- [x] **Task 3.1**: Secure Enclave keypair generation and storage
  - Success Criteria: One-time keypair generation on first launch, persistent storage
- [ ] **Task 3.2**: Create Secure Enclave manager with real cryptographic operations
  - Success Criteria: Real signing operations using Secure Enclave private key
- [ ] **Task 3.3**: Implement device compatibility checking and error handling
  - Success Criteria: Graceful degradation for devices without Secure Enclave
- [ ] **Task 3.4**: Update SignatureService to use real Secure Enclave signing
  - Success Criteria: Replace dummy signature with real cryptographic signatures
- [ ] **Task 3.5**: Add biometric authentication integration (optional)
  - Success Criteria: Touch ID/Face ID integration for enhanced security

### Phase 4: Real Photo Hashing Implementation (PLANNED)
- [ ] **Task 4.1**: Photo data extraction from PhotosPickerItem
  - Success Criteria: Extract real photo data from various formats (JPEG, HEIC, PNG)
  - Implementation: Use `PhotosPickerItem.loadTransferable(type: Data.self)`
- [ ] **Task 4.2**: SHA-256 hashing implementation using CryptoKit
  - Success Criteria: Real SHA-256 hashing of photo data, support for large files
  - Implementation: Use `SHA256.hash(data:)` with incremental hashing for large files
- [ ] **Task 4.3**: Secure Enclave integration for hash signing
  - Success Criteria: Hash photo data, immediately sign with Secure Enclave
  - Implementation: Photo → Hash → Secure Enclave Signature chain
- [ ] **Task 4.4**: Real hashing service implementation
  - Success Criteria: Replace DummyHashingService with RealHashingService
  - Implementation: Implement HashingService protocol with real operations
- [ ] **Task 4.5**: UI integration and progress indicators
  - Success Criteria: Show real hash values, progress for large files, responsive UI
  - Implementation: Update HomeViewModel and UI for real hashing

### Phase 5: Additional Screens & Polish
- [ ] **Task 5.1**: Create Result Screen
  - Success Criteria: Summary view with all data and copy buttons
- [ ] **Task 5.2**: Implement Settings Screen
  - Success Criteria: App version display
- [ ] **Task 5.3**: Add error handling and permissions
  - Success Criteria: Graceful UI for denied permissions and missing Secure Enclave

### Phase 6: Testing & Optimization
- [ ] **Task 6.1**: Implement unit tests for ViewModels and services
  - Success Criteria: Test coverage for all business logic
- [ ] **Task 6.2**: Performance optimization
  - Success Criteria: Pipeline completes <800ms, bundle size ≤18MB
- [ ] **Task 6.3**: UI testing and polish
  - Success Criteria: Haptics, animations, and error states working correctly

## Project Status Board

### Current Sprint: Phase 1 - Project Foundation ✅ COMPLETED
- [x] **Task 1.1**: Set up MVVM architecture with Combine
- [x] **Task 1.2**: Create service protocols and dummy implementations  
- [x] **Task 1.3**: Implement dependency injection container

### Current Sprint: Phase 2 - Core UI Components ✅ COMPLETED
- [x] **Task 2.1**: Design and implement Launch Screen
- [x] **Task 2.2**: Create HomeView with step progress indicator
- [x] **Task 2.3**: Implement photo picker and preview functionality

### Next Sprint: Phase 3 - Secure Enclave Implementation
- [x] **Task 3.1**: Secure Enclave keypair generation and storage
- [ ] **Task 3.2**: Create Secure Enclave manager with real cryptographic operations
- [ ] **Task 3.3**: Implement device compatibility checking and error handling
- [ ] **Task 3.4**: Update SignatureService to use real Secure Enclave signing
- [ ] **Task 3.5**: Add biometric authentication integration (optional)

### Backlog
- [ ] Phase 2.5: HEIC Format Implementation (Tasks 2.4-2.6)
- [ ] Phase 4: Real Photo Hashing Implementation (Tasks 4.1-4.5)
- [ ] Phase 5: Additional Screens & Polish (Tasks 5.1-5.3)
- [ ] Phase 6: Testing & Optimization (Tasks 6.1-6.3)

## Current Status / Progress Tracking

**Project Status**: Phase 2 - Core UI Components COMPLETED ✅
**Current Phase**: Ready to begin Phase 3 - Secure Enclave Implementation
**Next Milestone**: Real Secure Enclave keypair generation and cryptographic signing

**Completed Tasks**: 
- ✅ Task 1.1: Set up MVVM architecture with Combine
- ✅ Task 1.2: Create service protocols and dummy implementations
- ✅ Task 1.3: Implement dependency injection container
- ✅ Task 2.1: Design and implement Launch Screen
- ✅ Task 2.2: Create HomeView with step progress indicator
- ✅ Task 2.3: Implement photo picker and preview functionality

**In Progress**: None
**Blocked**: None

**Build Status**: ✅ SUCCESS - App compiles and builds successfully

## Executor's Feedback or Assistance Requests

**User Feedback - App Testing Complete ✅**
- App runs successfully in Xcode simulator
- All 4-step pipeline functionality working correctly
- Dark theme crypto aesthetic implemented properly
- Progress indicator and step flow working as expected

**New Requirement Identified:**
- **HEIC Format Restriction**: Only allow .heic format photos to be uploaded
- Need to implement automatic filtering to show only HEIC photos in the picker
- Prevent non-HEIC photos from being selected/uploaded

**Secure Enclave Implementation Requirements:**
- **One-time keypair generation** on first app launch
- **Persistent keypair storage** - same keypair used for all photo uploads
- **Real Secure Enclave signing** of photo hashes (currently dummy hashes)
- **Digital signature output** for cryptographic verification

## Lessons

*No lessons recorded yet*

## Technical Implementation Notes

### Core Architecture Pattern
```
Views (SwiftUI) → ViewModels (Combine) → Services (Protocols) → Implementations (Dummy/Real)
```

### Key Service Protocols
```swift
protocol HashingService {
    func hash(imageData: Data) async throws -> String
}

protocol SignatureService {
    func sign(hash: String) async throws -> (signature: String, publicKey: String)
}

protocol AttestationService {
    func attest(hash: String, signature: String, publicKey: String) async throws -> String
}
```

### Data Models Needed
- `PhotoData` - Image data and metadata
- `SignatureData` - Hash, signature, and public key
- `AttestationData` - Complete attestation result with transaction hash

### Dependency Injection Strategy
- Use `@EnvironmentObject` for service injection
- ServiceContainer class to manage service instances
- Easy swap from dummy to real implementations in Phase 2

### HEIC Format Implementation Strategy
```swift
// HEIC format detection
extension Data {
    var isHEIC: Bool {
        // Check for HEIC file signature
        return self.prefix(12).contains(where: { $0 == 0x00 }) && 
               self.prefix(4) == Data([0x00, 0x00, 0x00, 0x20])
    }
}

// PHPicker with format validation
PhotosPicker(selection: $selectedItem, matching: .images) {
    // Custom validation in onChange
}
```

### HEIC Validation Approach
1. **Client-side validation**: Check file format after selection
2. **User feedback**: Clear error messages for non-HEIC files
3. **Fallback handling**: Guide users when no HEIC photos available
4. **UI updates**: Indicate HEIC-only requirement in interface

### Secure Enclave Implementation Strategy
```swift
// Keypair generation and storage
class SecureEnclaveManager {
    private let keyTag = "com.z1.secureenclave.keypair"
    
    func generateKeyPair() async throws -> SecKey {
        // Generate ECDSA keypair in Secure Enclave
        // Store public key reference in Keychain
        // Return private key for signing operations
    }
    
    func sign(hash: Data) async throws -> Data {
        // Use Secure Enclave private key to sign hash
        // Return digital signature
    }
}

// Device compatibility checking
func isSecureEnclaveAvailable() -> Bool {
    // Check if device supports Secure Enclave (A11+)
    // Verify Secure Enclave is accessible
}
```

### Secure Enclave Flow
1. **First Launch**: Generate keypair, store public key reference
2. **Photo Upload**: Use existing private key to sign hash
3. **Persistence**: Same keypair used for all uploads
4. **Security**: Private key never leaves Secure Enclave 