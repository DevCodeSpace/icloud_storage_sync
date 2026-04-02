import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:icloud_storage_sync/models/icloud_file_download.dart';
import 'package:icloud_storage_sync_example/icloud_screen.dart';
import 'package:icloud_storage_sync_example/icloud_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

/// Controller class for managing iCloud-related operations
class IcloudController extends GetxController {
  // Add your iCloud container ID
  final iCloudContainerId = 'Add Your Project Container ID';

  // Observable map to store user data
  RxMap<String, dynamic> userData = <String, dynamic>{}.obs;

  // Observable list to store selected files
  RxList<File> selectedFiles = <File>[].obs;

  // Observable boolean for auto-sync feature
  RxBool iCloudIsAutoSync = false.obs;

  // Observable list to store relative paths of files selected for deletion
  RxList<String> selectedFilesRelativePath = <String>[].obs;
  // Observable boolean to toggle multiple file deletion mode
  RxBool isDeleteMultipleFiles = false.obs;

  // Observable enum to track iCloud storage connection state
  Rx<ICloudState> iCloudStorageState = ICloudState.notConnected.obs;

  // Instance of the iCloud sync plugin
  final icloudSyncPlugin = IcloudStorageSync();

  final searchIcloudFileController = TextEditingController().obs;

  // Observable list to store cloud files
  RxList<CloudFiles>? cloudFiles = <CloudFiles>[].obs;
  // Observable list of text editing controllers for cloud file names
  RxList<TextEditingController> cloudFilesNameList = <TextEditingController>[].obs;

  /// Initiates the Apple Sign-In process
  Future<void> signInWithApple(BuildContext context) async {
    try {
      // Perform Apple sign-in and get credentials
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Decode the identity token to extract user information
      String base64EncodedString = credential.identityToken!.split('.')[1];
      int paddingNeeded = 4 - (base64EncodedString.length % 4);
      base64EncodedString += "=" * paddingNeeded;
      List<int> decodedBytes = base64.decode(base64EncodedString);
      String decodedString = utf8.decode(decodedBytes);
      Map<String, dynamic> decodedJson = json.decode(decodedString);

      // Store user data in the observable map
      userData.value = {'id': credential.authorizationCode, 'token': credential.identityToken, 'email': decodedJson["email"]};

      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("userData", jsonEncode(userData));
      log("Sign-in successful: ${jsonEncode(userData)}");
      Get.snackbar("Success", "Sign-In Successful!");

      // Update iCloud storage state and navigate to iCloud screen
      iCloudStorageState.value = ICloudState.connected;
      Get.offAll(() => IcloudScreen(userData: userData));
    } catch (e) {
      Get.snackbar("Error", "Sign-In Unsuccessful!");
      debugPrint('Sign-in error: $e');
    }
  }

  /// Fetches the list of files from iCloud
  Future<List<CloudFiles>> getCloudFiles() async {
    return await icloudSyncPlugin.getCloudFiles(containerId: iCloudContainerId);
  }

  /// Allows the user to pick multiple files
  ///
  Future<void> pickMultipleFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );

      if (result != null) {
        List<File> files = result.paths.map((path) => File(path!)).toList();
        for (var file in files) {
          String fileName = path.basenameWithoutExtension(file.path);
          if (fileName.contains(".")) {
            Get.snackbar("Warning", "$fileName Please rename this file (.) not allow in file name", duration: const Duration(seconds: 2));
          } else {
            selectedFiles.add(file);
          }
        }

        if (iCloudIsAutoSync.value) {
          await uploadMultipleFileToICloud();
          await Future.delayed(const Duration(seconds: 1), () {});
        }
      } else {
        Get.snackbar("Warning", "Please select at least 1 file");
      }
    } catch (e) {
      debugPrint("--- error $e");
    }
  }

  /// Renames a file in iCloud
  Future<void> renameFile(CloudFiles oldFile, String newName) async {
    try {
      if (oldFile.relativePath != null) {
        await icloudSyncPlugin.rename(
          containerId: iCloudContainerId,
          newName: newName,
          relativePath: (oldFile.relativePath!).replaceAll('%20', ' '),
        );
      }
    } on PlatformException catch (e) {
      log("Failed to rename file in iCloud Drive: ${e.message}");
    }
  }

  /// replace a file in iCloud
  Future replaceFile({required String updatedFilePath, required String relativePath}) async {
    try {
      if (updatedFilePath.isNotEmpty && relativePath.isNotEmpty) {
        await icloudSyncPlugin.replace(
          containerId: iCloudContainerId,
          updatedFilePath: updatedFilePath,
          relativePath: relativePath,
        );
      }
    } on PlatformException catch (e) {
      log(" ${e.message}");
    }
  }

  /// Uploads a single file to iCloud
  Future<SynciCloudResult> uploadFileToICloud(String filePath) async {
    try {
      await icloudSyncPlugin
          .upload(
            containerId: iCloudContainerId,
            filePath: filePath,
          )
          .whenComplete(() {});
      await Future.delayed(const Duration(seconds: 2), () {});
      return SynciCloudResult.completed;
    } on PlatformException catch (e) {
      debugPrint("Failed to upload file to iCloud Drive: ${e.message}");
      return SynciCloudResult.failed;
    }
  }

  /// Uploads multiple files to iCloud
  Future<SynciCloudResult> uploadMultipleFileToICloud() async {
    try {
      await icloudSyncPlugin.uploadMultipleFileToICloud(containerId: iCloudContainerId, files: selectedFiles);
      selectedFiles.clear();
      debugPrint("All files uploaded successfully");
      return SynciCloudResult.completed;
    } catch (e) {
      debugPrint("Failed to upload files to iCloud Drive: $e");
      return SynciCloudResult.failed;
    }
  }

  /// Deletes a single file from iCloud
  Future<bool?> deleteFileFromiCloud({required String relativePath}) async {
    try {
      await icloudSyncPlugin.delete(containerId: iCloudContainerId, relativePath: relativePath, isDirectory: false);
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      debugPrint('Error while deleting file from iCloud: ${e.toString()}');
    }
    return null;
  }

  /// Deletes multiple files from iCloud
  Future<SynciCloudResult> deleteMultipleFileFromiCloud() async {
    try {
      await icloudSyncPlugin.deleteMultipleFileToICloud(containerId: iCloudContainerId, relativePathList: selectedFilesRelativePath);
      await Future.delayed(const Duration(seconds: 3));
      selectedFilesRelativePath.clear();
      return SynciCloudResult.completed;
    } catch (e) {
      debugPrint('Error while deleting files from iCloud: ${e.toString()}');
      return SynciCloudResult.failed;
    }
  }

  /// Extracts the original file name from a potentially modified file name
  String getCleanFileName(String fileName) {
    List<String> parts = fileName.split('-');
    if (parts.isNotEmpty) {
      return parts[0]; // Return the first part, which is the original file name
    }
    return fileName; // Return the original file name if no dash is found
  }
}
