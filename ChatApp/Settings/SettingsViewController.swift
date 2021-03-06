//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by Den on 2020-09-30.
//  Copyright © 2020 Den. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    private lazy var settingsModel = SettingsModel(view: self)
    weak var coordinator: MainCoordinator?

    private var user: ChatUser?
    
    var updateUserAction: ((ChatUser) -> Void)?
    var updateUserAvatarAction: ((UIImage) -> Void)?
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var setAvatarPhotoButton: UIButton!
    @IBOutlet private weak var userIntialsLabel: UILabel!
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = settingsModel
        avatarImageView.setBorder()
        usernameTextField.delegate = self
    }
    
    func setupUser(_ user: ChatUser) {
        _ = view
        usernameTextField.text = user.name
        emailLabel.text = user.email
        if let avatar = user.avatar {
            setupAvatar(image: avatar)
        }
        userIntialsLabel.text = String(user.name.prefix(2))
        self.user = user
    }
    
    func changedPassword(_ successful: Bool) {
        let alert = UIAlertController(title: successful ? "Success" : "Fail",
                                      message: successful ? "Password is changed"
                                                          : "Password is not changed",
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func setupAvatar(image: UIImage) {
        avatarImageView.image = image
        userIntialsLabel.isHidden = true
    }
    
    @IBAction private func setAvatarButtonAction(_ sender: Any) {
        showImagePicker()
    }
    
    @IBAction private func changePasswordButtonAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter new password",
                                                message: "",
                                                preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { _ in
            // textField.placeholder = "Enter new password"
        }
        let saveAction = UIAlertAction(title: "Confirm",
                                       style: UIAlertAction.Style.default,
                                       handler: { _ in
            guard let textFields = alertController.textFields else { return }
            let passwordTextField = textFields[0] as UITextField
            guard let password = passwordTextField.text, !password.isEmpty
                else { return }
            self.settingsModel.setNewPassword(password)
        })
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertAction.Style.default,
                                         handler: { _ in })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}


// MARK: - Image picker

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showImagePicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage,
              let imageData = image.jpegData(compressionQuality: 1),
              let userEmail = user?.email
            else { return }
        dismiss(animated: true)
        setupAvatar(image: image)
        user?.avatar = image
        updateUserAvatarAction?(image)
        settingsModel.saveImageToServer(imageData, for: userEmail)
    }
    
}


// MARK: - Username

extension SettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        guard let newName = textField.text else { return true }
        self.user?.name = newName
        userIntialsLabel.text = String(newName.prefix(2))
        if let user = user {
            updateUserAction?(user)
        }
        settingsModel.saveUsernameToServer(newName)
        return true
    }
    
}
