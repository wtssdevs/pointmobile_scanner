import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class FileStoreManager {
  final log = getLogger('FileStoreManager');
  final ApiManager _apiManager = locator<ApiManager>();
  final FileStoreRepository _fileStoreRepository =
      locator<FileStoreRepository>();

  // Isolate management
  Isolate? _uploadIsolate;
  SendPort? _uploadSendPort;
  ReceivePort? _uploadReceivePort;
  bool _isolateReady = false;
  final Map<String, Completer<Map<String, dynamic>>> _pendingUploads = {};

  // Configuration
  bool _useIsolate = true;

  /// Static entry point for file upload isolate
  static void fileUploadIsolateEntry(SendPort mainSendPort) async {
    final isolateReceivePort = ReceivePort();

    // Send isolate's SendPort back to main
    mainSendPort.send(isolateReceivePort.sendPort);

    // Listen for upload jobs
    await for (final message in isolateReceivePort) {
      if (message == 'shutdown') {
        break;
      } else if (message is Map<String, dynamic>) {
        await _handleFileUploadInIsolate(message, mainSendPort);
      }
    }
  }

  /// Handle file upload within the isolate
  static Future<void> _handleFileUploadInIsolate(
      Map<String, dynamic> jobData, SendPort mainSendPort) async {
    final jobId = jobData['jobId'] as String;

    try {
      final result = await _performFileUploadWithDio(jobData);

      // Send success result back to main isolate
      mainSendPort.send({
        'jobId': jobId,
        'success': true,
        'result': result,
      });
    } catch (e) {
      // Send error result back to main isolate
      mainSendPort.send({
        'jobId': jobId,
        'success': false,
        'error': e.toString(),
      });
    }
  }

  /// Perform the actual file upload using Dio in isolate
  static Future<Map<String, dynamic>> _performFileUploadWithDio(
      Map<String, dynamic> jobData) async {
    final filePath = jobData['filePath'] as String;
    final fileName = jobData['fileName'] as String;
    final apiBaseUrl = jobData['apiBaseUrl'] as String;
    final authToken = jobData['authToken'] as String;
    final refId = jobData['refId'] as String;
    final filestoreType = jobData['filestoreType'] as String;
    final fileStoreId = jobData['fileStoreId'] as String;
    final connectTimeout = jobData['connectTimeout'] as int? ?? 30000;
    final receiveTimeout = jobData['receiveTimeout'] as int? ??
        300000; // 5 minutes for large files
    final allowedHosts = jobData['allowedHosts'] as List<String>? ?? [];

    // Validate file exists
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File not found: $filePath');
    } // Create HttpClient with SSL override for isolate
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Debug certificate information
        if (kDebugMode) {
          _debugSSLCertificate(cert, host);
        }

        return _validateSSLHost(host, allowedHosts, apiBaseUrl);
      };

    // Create Dio instance for isolate (can't share instances across isolates)
    final dio = Dio(BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: receiveTimeout),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      },
    ));

    // Set the custom HttpClient adapter for SSL handling
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient =
        () => httpClient;

    // Add interceptors for logging (optional)
    dio.interceptors.add(LogInterceptor(
      requestBody: false, // Don't log file data
      responseBody: true,
      logPrint: (obj) {
        // Custom logging for isolate

        if (kDebugMode) {
          print('Dio Isolate: $obj');
        }
      },
    ));

    try {
      // Prepare multipart file
      final multipartFile = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        headers: {
          "fileStoreType": [filestoreType],
          "transactionRefId": [refId],
        },
      );

      // Create form data
      final formData = FormData.fromMap({
        'files': multipartFile,
      });

      // Upload file
      final response = await dio.post(
        AppConst.FileUploading_Images,
        data: formData,
        options: Options(
          headers: {
            "fileStoreType": filestoreType,
            "transactionRefId": refId,
            "overrideExisting": "true",
            "name": fileName,
            "antiForgeryToken": "",
          },
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (sent, total) {
          // Progress tracking (could send updates back to main isolate if needed)
          final progress = (sent / total * 100).toStringAsFixed(1);
          if (kDebugMode) {
            print('Upload progress for $fileName: $progress%');
          }
        },
      );

      // Get file stats
      final fileStats = await file.stat();

      if (response.statusCode == 200) {
        return {
          'fileStoreId': fileStoreId,
          'refId': refId,
          'fileName': fileName,
          'filePath': filePath,
          'uploadedAt': DateTime.now().toIso8601String(),
          'fileSize': fileStats.size,
          'uploadDuration': DateTime.now()
              .difference(DateTime.parse(
                  jobData['startTime'] ?? DateTime.now().toIso8601String()))
              .inMilliseconds,
          'serverResponse': response.data,
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Upload failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'Upload failed: ';

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage += 'Connection timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage += 'Send timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage += 'Receive timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage += 'Server error: ${e.response?.statusCode}';
          break;
        case DioExceptionType.cancel:
          errorMessage += 'Request cancelled';
          break;
        case DioExceptionType.connectionError:
          errorMessage += 'Connection error';
          break;
        case DioExceptionType.unknown:
          errorMessage += 'Unknown error:${e.error} ${e.message}';
          break;
        default:
          errorMessage += e.message ?? 'Unknown error';
      }

      throw Exception(errorMessage);
    } finally {
      dio.close();
    }
  }

  /// Initialize the upload isolate
  Future<void> initializeIsolate() async {
    if (_isolateReady || !_useIsolate) return;

    try {
      _uploadReceivePort = ReceivePort();

      // Spawn the isolate
      _uploadIsolate = await Isolate.spawn(
          fileUploadIsolateEntry, _uploadReceivePort!.sendPort);

      // Listen for responses and isolate SendPort
      _uploadReceivePort!.listen((message) {
        if (message is SendPort) {
          // Isolate is ready
          _uploadSendPort = message;
          _isolateReady = true;
          log.i('File upload isolate initialized successfully');
        } else if (message is Map<String, dynamic>) {
          // Handle upload result
          _handleUploadResult(message);
        }
      });

      // Wait for isolate to be ready
      await _waitForIsolateReady();
    } catch (e) {
      log.e('Failed to initialize file upload isolate: $e');
      _useIsolate = false;
      _disposeIsolate();
    }
  }

  /// Wait for isolate to be ready
  Future<void> _waitForIsolateReady() async {
    var attempts = 0;
    const maxAttempts = 50; // 5 seconds timeout

    while (!_isolateReady && attempts < maxAttempts) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    if (!_isolateReady) {
      throw Exception('Isolate initialization timeout');
    }
  }

  /// Handle upload result from isolate
  void _handleUploadResult(Map<String, dynamic> result) {
    final jobId = result['jobId'] as String;
    final completer = _pendingUploads.remove(jobId);

    if (completer != null) {
      if (result['success'] == true) {
        completer.complete(result['result']);
      } else {
        completer.completeError(Exception(result['error']));
      }
    }
  }

  /// Upload file using isolate
  Future<Map<String, dynamic>> uploadFileInIsolate(FileStore fileStore) async {
    if (!_useIsolate) {
      // Fallback to main isolate using existing API manager
      return await _uploadFileMainIsolate(fileStore);
    }

    if (!_isolateReady) {
      await initializeIsolate();
    }

    if (!_isolateReady) {
      // Fallback if isolate failed to initialize
      return await _uploadFileMainIsolate(fileStore);
    }

    final jobId = DateTime.now().millisecondsSinceEpoch.toString();
    final completer = Completer<Map<String, dynamic>>();
    _pendingUploads[jobId] = completer;

    // Prepare job data
    final jobData = await _prepareUploadJobData(fileStore, jobId);

    // Send job to isolate
    _uploadSendPort!.send(jobData);

    // Return future that completes when isolate responds
    return completer.future.timeout(
      const Duration(minutes: 10), // Increased timeout for large files
      onTimeout: () {
        _pendingUploads.remove(jobId);
        throw TimeoutException(
            'File upload timeout', const Duration(minutes: 10));
      },
    );
  }

  /// Prepare upload job data with Dio configuration
  Future<Map<String, dynamic>> _prepareUploadJobData(
      FileStore fileStore, String jobId) async {
    final environmentService = locator<EnvironmentService>();
    final localStorageService = locator<LocalStorageService>();
    var token = localStorageService.getAuthToken;
    if (token == null) {
      throw Exception('Access token is null, cannot upload file');
    }

    if (token.accessToken == null) {
      throw Exception('Access token is null, cannot upload file');
    }

    return {
      'jobId': jobId,
      'filePath': fileStore.path,
      'fileName': fileStore.fileName,
      'refId': fileStore.refId,
      'fileStoreId': fileStore.id,
      'apiBaseUrl': environmentService.baseUrl,
      'authToken': token.accessToken,
      'filestoreType': fileStore.filestoreType.toString(),
      'connectTimeout': 30000, // 30 seconds
      'receiveTimeout': 300000, // 5 minutes
      'startTime': DateTime.now().toIso8601String(),
      'allowedHosts': AppConst.sslAllowedHosts,
    };
  }

  /// Fallback upload method using existing API manager
  Future<Map<String, dynamic>> _uploadFileMainIsolate(
      FileStore fileStore) async {
    final startTime = DateTime.now();

    try {
      await _apiManager.uploadLoadImages(fileStore);

      return {
        'fileStoreId': fileStore.id,
        'refId': fileStore.refId,
        'fileName': fileStore.fileName,
        'uploadedAt': DateTime.now().toIso8601String(),
        'uploadDuration': DateTime.now().difference(startTime).inMilliseconds,
        'method': 'main_isolate_api_manager',
      };
    } catch (e) {
      throw Exception('Main isolate upload failed: $e');
    }
  }

  /// Public API methods (enhanced with isolate support)

  /// Upload image to server with isolate support
  Future<void> uploadImageToServer(String refId) async {
    var fileStore = await _fileStoreRepository.getByRefId(refId);

    if (fileStore != null) {
      try {
        final result = await uploadFileInIsolate(fileStore);

        // Update filestore record
        fileStore.upLoaded = true;
        await _fileStoreRepository.update(fileStore);

        log.i(
            'File uploaded successfully: ${result['fileName']} in ${result['uploadDuration']}ms');
      } catch (e) {
        log.e('Failed to upload file for refId $refId: $e');
        rethrow;
      }
    } else {
      log.w('FileStore not found for refId: $refId');
    }
  }

  /// Batch upload multiple files with progress tracking
  Future<List<Map<String, dynamic>>> uploadMultipleFiles(
      List<String> refIds) async {
    final results = <Map<String, dynamic>>[];

    log.i('Starting batch upload of ${refIds.length} files');

    for (int i = 0; i < refIds.length; i++) {
      final refId = refIds[i];
      try {
        final fileStore = await _fileStoreRepository.getByRefId(refId);
        if (fileStore != null) {
          log.d(
              'Uploading file ${i + 1}/${refIds.length}: ${fileStore.fileName}');

          final result = await uploadFileInIsolate(fileStore);
          results.add(result);

          fileStore.upLoaded = true;
          await _fileStoreRepository.update(fileStore);

          log.d('Completed upload ${i + 1}/${refIds.length}');
        }
      } catch (e) {
        log.e('Failed to upload file for refId $refId: $e');
        results.add({
          'refId': refId,
          'error': e.toString(),
          'success': false,
        });
      }
    }

    log.i('Batch upload completed: ${results.length} files processed');
    return results;
  }

  /// Clear old files
  Future<void> clearOld() async {
    await _fileStoreRepository.clearOldImages();
  }

  /// Delete images on server using existing API manager
  Future<void> deleteImagesOnServer(int stepId, String fileName) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    queryParameters['searchValue'] = fileName;
    queryParameters['refreanceId'] = stepId;

    await _apiManager.post("/api/services/app/FileStore/StepImageDelete",
        data: queryParameters, showLoader: false);
  }

  /// Configure isolate usage
  void setUseIsolate(bool useIsolate) {
    if (_useIsolate != useIsolate) {
      _useIsolate = useIsolate;
      log.i('File upload isolate usage changed to: $useIsolate');

      if (!useIsolate) {
        _disposeIsolate();
      }
    }
  }

  /// Get upload statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isolateReady': _isolateReady,
      'useIsolate': _useIsolate,
      'pendingUploads': _pendingUploads.length,
      'isolateMode': _useIsolate ? 'enabled' : 'disabled',
      'httpClient': 'dio',
      'pendingJobIds': _pendingUploads.keys.toList(),
    };
  }

  /// Test upload functionality
  Future<bool> testUpload() async {
    try {
      // This could test with a small dummy file
      final stats = getStatistics();
      log.i('Upload test - Current stats: $stats');
      return _isolateReady || !_useIsolate;
    } catch (e) {
      log.e('Upload test failed: $e');
      return false;
    }
  }

  /// Test isolate functionality and SSL configuration
  Future<bool> testIsolateConfiguration() async {
    try {
      log.i('Testing isolate configuration...');

      // Initialize isolate if not ready
      if (!_isolateReady) {
        await initializeIsolate();
      }

      if (_isolateReady) {
        log.i('Isolate configuration test: SUCCESS');
        return true;
      } else {
        log.w('Isolate configuration test: FAILED - Isolate not ready');
        return false;
      }
    } catch (e) {
      log.e('Isolate configuration test: FAILED - $e');
      return false;
    }
  }

  /// Dispose isolate resources
  void _disposeIsolate() {
    if (_uploadSendPort != null) {
      _uploadSendPort!.send('shutdown');
    }

    _uploadIsolate?.kill();
    _uploadReceivePort?.close();

    _uploadIsolate = null;
    _uploadSendPort = null;
    _uploadReceivePort = null;
    _isolateReady = false;

    // Complete any pending uploads with error
    for (final completer in _pendingUploads.values) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Isolate disposed'));
      }
    }
    _pendingUploads.clear();
  }

  /// Cleanup resources
  Future<void> dispose() async {
    log.i('Disposing FileStoreManager');
    _disposeIsolate();
  }

  /// Enhanced SSL validation with host extraction from base URL
  static bool _validateSSLHost(
      String host, List<String> allowedHosts, String apiBaseUrl) {
    // Extract host from API base URL for additional validation
    try {
      final uri = Uri.parse(apiBaseUrl);
      final baseHost = uri.host;

      // Check if the host matches the base URL host or is in allowed hosts using AppConst
      final isValidHost = AppConst.isSSLHostAllowed(host) || host == baseHost;

      if (kDebugMode) {
        print(
            "Enhanced SSL validation - Host: $host, BaseHost: $baseHost, Valid: $isValidHost");
      }
      return isValidHost;
    } catch (e) {
      if (kDebugMode) {
        print("SSL validation error: $e");
      }
      // Fallback to simple allowed hosts check using AppConst
      return AppConst.isSSLHostAllowed(host);
    }
  }

  /// Debug SSL certificate information
  static void _debugSSLCertificate(X509Certificate cert, String host) {
    try {
      if (!kDebugMode) return; // Only log in debug mode

      print("SSL Debug - Host: $host");
      print("SSL Debug - Subject: ${cert.subject}");
      print("SSL Debug - Issuer: ${cert.issuer}");
      print("SSL Debug - Start Date: ${cert.startValidity}");
      print("SSL Debug - End Date: ${cert.endValidity}");
    } catch (e) {
      print("SSL Debug Error: $e");
    }
  }
}
