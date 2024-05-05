//
//  ProfileCustomizationViewController.swift
//  Final Project Stellar
//
//  Created by Michael Tapia on 5/3/24.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Photos

class ProfileCustomizationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    var imagePickerController = UIImagePickerController()
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        avatarButton.layer.cornerRadius = 5.0
        avatarButton.layer.borderWidth = 1.0
        avatarButton.layer.borderColor = UIColor.gray.cgColor
        imagePickerController.delegate = self
        checkPermissions()
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func continueToProfile(_ sender: Any) {
        guard let username = usernameTextField.text else {return}
        
        let database = Database.database().reference()
        if let currentUser = Auth.auth().currentUser {
            let userRef = database.child("users").child(currentUser.uid)
            userRef.setValue(["username": username]) { error, _ in
                if let error = error {
                    print("Error saving username: \(error.localizedDescription)")
                } else {
                    print("Username saved successfully!")
                }
            }
            self.performSegue(withIdentifier: "GoToProfile", sender: self)
        }
    }
    
    
    @IBAction func changeAvtarPressed(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in ()
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
        } else {
            PHPhotoLibrary
                .requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Access granted to use Photo Library")
        } else {
            print("We don't have access to your Photos.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage,
        let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            uploadProfilePic(imageData: imageData)
        }
        
        if picker.sourceType == .photoLibrary {
            profilePic?.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        }
        else {
            profilePic?.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
        
        
    }
    
    func uploadProfilePic(imageData: Data) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let userUID = Auth.auth().currentUser?.uid ?? "unknown_user"
        let profileImagePath = "images/\(userUID).jpg"
        let profileImageRef = storageRef.child(profileImagePath)
        
        // 3. Upload image data using putData
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg" // Adjust based on your image format
        
        profileImageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Error uploading profile picture: \(error.localizedDescription)")
                // Handle the error (e.g., show an alert to the user)
            } else {
                // 4. Get the download URL
                profileImageRef.downloadURL { url, error in
                    if let downloadURL = url {
                        print("Profile picture uploaded successfully. URL: \(downloadURL)")
                        
                        // 5. Save the URL to the Realtime Database
                        self.saveProfileImageURL(downloadURL)
                    } else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
    
    func saveProfileImageURL(_ url: URL) {
        guard let currentUser = Auth.auth().currentUser else {
            print("User not authenticated. Cannot save profile image URL.")
            return
        }
        let userRef = Database.database().reference().child("users").child(currentUser.uid)
        let profileImageUrl = url.absoluteString
        
        // Update the "profileImageUrl" field in the Realtime Database
        userRef.child("images").setValue(profileImageUrl) { error, _ in
            if let error = error {
                print("Error saving profile image URL: \(error.localizedDescription)")
                // Handle the error (e.g., show an alert to the user)
            } else {
                print("Profile image URL saved successfully.")
                // You can perform any additional actions here
            }
        }
    

        // Save the URL to the Realtime Database (e.g., under "users/userUID/profileImageUrl")
        // You can use DatabaseReference to update the value
        // Example:
        // let userRef = Database.database().reference().child("users").child(userUID)
        // userRef.child("profileImageUrl").setValue(url.absoluteString)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
