# 📱 iCloud_Storage_Sync Example

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Apple](https://img.shields.io/badge/Apple-%23000000.svg?style=for-the-badge&logo=apple&logoColor=white)

This Flutter application demonstrates how to integrate iCloud synchronization functionality into your app, allowing users to sign in with their Apple ID and manage files in iCloud storage. 🚀

## ✨ Features

 🍎 Apple Sign In integration

 ☁️ iCloud file synchronization

 📂 File management (upload, download, rename, delete)
 
 🖼️ User-friendly interface for file operations

<br>

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Xcode (for iOS development)
- Apple Developer account

### 🛠️ Installation

1. Clone this repository:
   ```sh
   git clone https://github.com/DevCodeSpace/icloud_storage_sync.git
   ```
2. Navigate to the project directory:
   ```sh
   cd icloud_storage_sync
   ```
3. Install dependencies:
   ```sh
   flutter pub get
   ```

### ⚙️ Configuration

1. Set up your Apple Developer account and configure your app for iCloud capabilities.
2. In `icloud_plugin_controller.dart`, replace the `iCloudContainerId` with your actual iCloud container ID:
   ```dart
   final iCloudContainerId = 'your.icloud.container.id';
   ```

## 📱 Usage

1. Run the app:
   ```sh
   flutter run
   ```
2. Sign in with your Apple ID on the initial screen.
3. Once signed in, you can:
   - 👀 View files stored in iCloud
   - 📤 Upload new files
   - ✏️ Rename existing files
   - 🗑️ Delete files from iCloud storage

## 💻 Code Examples

### 🍎 Apple Sign In

```dart
Future<void> signInWithApple(context) async {
  try {
    // Request Apple ID credentials
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    
    // Process and store the credential
    // ... (Code for processing and storing credential)

    // Update iCloud connection state
    iCloudStorageState.value = ICloudState.connected;

    // Navigate to iCloud screen
    Get.offAll(() => IcloudScreen(userData: userData));
  } catch (e) {
    // Handle sign-in errors
    Get.snackbar("Error", "Sign-In Unsuccessful!");
    debugPrint('Sign-in error: $e');
  }
}
```

### 📤 Uploading a File to iCloud

```dart
Future<SynciCloudResult> uploadFileToICloud(String filePath) async {
  try {
    // Attempt to upload file to iCloud
    await icloudSyncPlugin.upload(
      containerId: iCloudContainerId,
      filePath: filePath,
    );
    
    // Return success status
    return SynciCloudResult.completed;
  } on PlatformException catch (e) {
    // Log error and return failure status
    debugPrint("Failed to upload file to iCloud Drive: ${e.message}");
    return SynciCloudResult.failed;
  }
}
```

### ✏️ Renaming a File in iCloud

```dart
Future<void> renameFile(CloudFiles oldFile, String newName) async {
  try {
    if (oldFile.relativePath != null) {
      // Attempt to rename file in iCloud
      await icloudSyncPlugin.rename(
        containerId: iCloudContainerId,
        newName: newName,
        relativePath: (oldFile.relativePath!).replaceAll('%20', ' '),
      );
    }
  } on PlatformException catch (e) {
    // Log error if renaming fails
    log("Failed to rename file in iCloud Drive: ${e.message}");
  }
}
```

### 🔄 Replace a File in iCloud

```dart
Future replaceFile(
    {required String updatedFilePath, required String relativePath}) async {
  try {
    if (updatedFilePath.isNotEmpty && relativePath.isNotEmpty) {
      await icloudSyncPlugin.replace(
        containerId: iCloudContainerId,
        updatedFilePath: updatedFilePath,
        relativePath: relativePath,
      );
    }
  } on PlatformException catch (e) {
    log("replace file failed ${e.message}");
  }
}
```

### 🗑️ Deleting a File from iCloud

```dart
Future<bool?> deleteFileFromiCloud({required String relativePath}) async {
  try {
    // Attempt to delete file from iCloud
    await icloudSyncPlugin.delete(
      containerId: iCloudContainerId,
      relativePath: Uri.decodeComponent(relativePath)
      isDirectory: false
    );
    
    // Return true if deletion is successful
    return true;
  } catch (e) {
    // Log error and return null if deletion fails
    debugPrint('Error while deleting file from iCloud: ${e.toString()}');
    return null;
  }
}
```

## 📁 Project Structure

- `main.dart`: Entry point of the application
- `apple_sign.dart`: Handles Apple Sign In functionality
- `icloud_screen.dart`: Main screen for iCloud file management
- `icloud_plugin_controller.dart`: Controller for iCloud operations
- `icloud_state.dart`: Enums for iCloud connection states

## 📚 To Enhance Functionality

- `get`: State management
- `iCloud_Storage_Sync`: iCloud synchronization
- `file_picker`: File selection
- `sign_in_with_apple`: Apple Sign In integration
- `shared_preferences`: Local data storage


---

<p align="center">
  Made with ❤️ by DevCodeSpace 
</p>