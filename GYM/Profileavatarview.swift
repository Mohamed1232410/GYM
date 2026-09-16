//
//  Untitled.swift
//  GYM
//
//  Created by Mohamed ahmed on 23/05/2026.
//

import SwiftUI
import PhotosUI

// MARK: - Profile Avatar View (used in Profile + Home headers)
struct ProfileAvatarView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    var size: CGFloat = 70
    var showEditBadge: Bool = false
    var onTap: (() -> Void)? = nil

    var initials: String {
        let parts = userProfileVM.profile.name
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(userProfileVM.profile.name.prefix(2)).uppercased().ifEmpty("?")
    }

    var body: some View {
        Button(action: { onTap?() }) {
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let img = userProfileVM.profileImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: size, height: size)
                            .overlay(
                                Text(initials)
                                    .font(.system(size: size * 0.32, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

                if showEditBadge {
                    Circle()
                        .fill(Color.green)
                        .frame(width: size * 0.32, height: size * 0.32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.system(size: size * 0.13))
                                .foregroundColor(.white)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 3)
                        .offset(x: 2, y: 2)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(onTap == nil)
    }
}

// MARK: - Photo Source Action Sheet + Picker coordinator
struct ProfilePhotoPickerView: View {
    @EnvironmentObject var userProfileVM: UserProfileViewModel
    @Binding var isPresented: Bool

    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        // Invisible trigger — shows action sheet as soon as isPresented = true
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear { showActionSheet = true }
            .confirmationDialog("Change Profile Photo", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Take Photo") {
                    sourceType = .camera
                    showCamera = true
                }
                Button("Choose from Library") {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }
                if userProfileVM.profileImage != nil {
                    Button("Remove Photo", role: .destructive) {
                        userProfileVM.removeProfileImage()
                        isPresented = false
                    }
                }
                Button("Cancel", role: .cancel) {
                    isPresented = false
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: { isPresented = false }) {
                LegacyImagePicker(sourceType: .photoLibrary) { image in
                    userProfileVM.saveProfileImage(image)
                }
            }
            .sheet(isPresented: $showCamera, onDismiss: { isPresented = false }) {
                LegacyImagePicker(sourceType: .camera) { image in
                    userProfileVM.saveProfileImage(image)
                }
            }
    }
}

// MARK: - UIImagePickerController wrapper
struct LegacyImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.allowsEditing = true   // built-in circular crop
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage) -> Void
        init(onImagePicked: @escaping (UIImage) -> Void) { self.onImagePicked = onImagePicked }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            if let img = image { onImagePicked(img) }
            picker.dismiss(animated: true)
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Helpers
private extension String {
    func ifEmpty(_ fallback: String) -> String { isEmpty ? fallback : self }
}
