import 'package:flutter_test/flutter_test.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:icloud_storage_sync/icloud_storage_sync_platform_interface.dart';
import 'package:icloud_storage_sync/icloud_storage_sync_method_channel.dart';
import 'package:icloud_storage_sync/models/icloud_file.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockIcloudStorageSyncPlatform
    with MockPlatformInterfaceMixin
    implements IcloudStorageSyncPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<String?> getContainerUrl({required String containerId}) =>
      throw UnimplementedError();

  @override
  Future<void> delete(
      {required String containerId, required String relativePath}) {
    throw UnimplementedError();
  }

  @override
  Future<void> download(
      {required String containerId,
      required String relativePath,
      required String destinationFilePath,
      StreamHandler<double>? onProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<List<ICloudFile>> gather(
      {required String containerId,
      StreamHandler<List<ICloudFile>>? onUpdate}) {
    throw UnimplementedError();
  }

  @override
  Future getCloudFiles({required String containerId}) {
    throw UnimplementedError();
  }

  @override
  Future<void> move(
      {required String containerId,
      required String fromRelativePath,
      required String toRelativePath}) {
    throw UnimplementedError();
  }

  @override
  Future<void> upload(
      {required String containerId,
      required String filePath,
      required String destinationRelativePath,
      StreamHandler<double>? onProgress}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isICloudAvailable() {
    throw UnimplementedError();
  }
}

void main() {
  final IcloudStorageSyncPlatform initialPlatform =
      IcloudStorageSyncPlatform.instance;

  test('$MethodChannelIcloudStorageSync is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIcloudStorageSync>());
  });

  test('getPlatformVersion', () async {
    IcloudStorageSync icloudStorageSyncPlugin = IcloudStorageSync();
    MockIcloudStorageSyncPlatform fakePlatform =
        MockIcloudStorageSyncPlatform();
    IcloudStorageSyncPlatform.instance = fakePlatform;

    expect(await icloudStorageSyncPlugin.getPlatformVersion(), '42');
  });
}
