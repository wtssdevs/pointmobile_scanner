import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_manager.dart';

@LazySingleton()
class FileStoreIsolateInitializer {
  static final log = getLogger('FileStoreIsolateInitializer');

  /// Initialize FileStore isolate during app startup
  Future<void> initializeFileStoreIsolate() async {
    try {
      log.i('Initializing FileStore isolate...');

      final fileStoreManager = locator<FileStoreManager>();

      // Test isolate configuration
      final isConfigured = await fileStoreManager.testIsolateConfiguration();

      if (isConfigured) {
        log.i('FileStore isolate initialized and configured successfully');
      } else {
        log.w(
            'FileStore isolate initialization failed - falling back to main isolate uploads');
        fileStoreManager.setUseIsolate(false);
      }

      // Log configuration status
      final stats = fileStoreManager.getStatistics();
      log.i('FileStore configuration: $stats');
    } catch (e) {
      log.e('FileStore isolate initialization error: $e');

      // Ensure fallback is configured
      try {
        final fileStoreManager = locator<FileStoreManager>();
        fileStoreManager.setUseIsolate(false);
        log.i('Configured FileStore to use main isolate fallback');
      } catch (fallbackError) {
        log.e('Failed to configure fallback: $fallbackError');
      }
    }
  }

  /// Test SSL configuration with a specific host
  static Future<bool> testSSLConfiguration(String testHost) async {
    try {
      log.i('Testing SSL configuration for host: $testHost');

      // Check if the host is in our allowed list using AppConst helper
      final isAllowed = AppConst.isSSLHostAllowed(testHost);
      log.i(
          'Host $testHost is ${isAllowed ? 'allowed' : 'not allowed'} in SSL configuration');

      return isAllowed;
    } catch (e) {
      log.e('SSL configuration test failed: $e');
      return false;
    }
  }

  /// Get all allowed SSL hosts for debugging
  static List<String> getAllowedSSLHosts() {
    return AppConst.getSSLAllowedHosts();
  }
}
