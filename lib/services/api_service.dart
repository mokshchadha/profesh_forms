import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:profesh_forms/components/dialogues.dart';
import 'package:profesh_forms/services/local_storage.dart';
import 'package:profesh_forms/constants.dart';

class ApiService {
  final _client = http.Client();
  String get baseUrl => serverUrl;

  Future<dynamic> getJobDetails(String projectHash) async {
    try {
      final url = '$baseUrl/$apiV1/project/$projectHash/public-details';
      final response = await getRequest(url);

      if (response['error'] == null) {
        return {
          'success': true,
          'title': response['projectName'] ?? 'Job Position',
          'company': response['companyName'] ?? 'Company',
          'description':
              response['description'] ?? 'Job description not available',
          'location': response['location'] ?? 'Location not specified',
          'type': response['type'] ?? 'Full-time',
          'stipend': response['stipend'],
          'logo': response['logo'],
          'videoUrl': response['videoUrl'] ?? '',
          'jdPdf': response['jdPdf'] ?? '',
        };
      } else {
        debugPrint('Error getting job details: ${response['error']}');
        return {'success': false, 'error': response['error']};
      }
    } catch (e) {
      debugPrint('Exception in getJobDetails: $e');
      return {'success': false, 'error': 'Failed to load job details'};
    }
  }

  Future<dynamic> checkApplicationStatus(
    String projectHash,
    String email,
    String phone,
  ) async {
    try {
      final url = '$baseUrl/$apiV1/candidates/public-form-application';
      final body = {'email': email, 'phone': phone};

      final response = await postRequest(url, body);

      if (response['error'] == null) {
        return {
          'success': true,
          'alreadyApplied': response['isApplied'] ?? false,
          'userId': response['userId'],
          'message': response['isApplied'] == true
              ? 'You have already applied for this position'
              : 'You can proceed with the application',
        };
      } else {
        debugPrint('Error checking application status: ${response['error']}');
        return {'success': false, 'error': response['error']};
      }
    } catch (e) {
      debugPrint('Exception in checkApplicationStatus: $e');
      return {'success': false, 'error': 'Failed to check application status'};
    }
  }

  Future<dynamic> uploadCV(
    String projectHash,
    File cvFile,
    Map<String, String> userData,
  ) async {
    try {
      final uploadUrl = '$baseUrl/$apiV1/upload/resume';
      final uploadResponse = await multipartRequestFile(
        uploadUrl,
        cvFile,
        'resume',
      );

      if (uploadResponse['error'] == null) {
        final resumeUrl = uploadResponse['url'] ?? uploadResponse['fileUrl'];

        await LocalStorageService().setData('resumeUrl', resumeUrl);

        return {
          'success': true,
          'message': 'CV uploaded successfully',
          'cvUrl': resumeUrl,
        };
      } else {
        return {'success': false, 'error': uploadResponse['error']};
      }
    } catch (e) {
      debugPrint('Exception in uploadCV: $e');
      return {'success': false, 'error': 'Failed to upload CV'};
    }
  }

  Future<dynamic> uploadVideo(
    String projectHash,
    File videoFile,
    Map<String, String> userData,
  ) async {
    try {
      final uploadUrl = '$baseUrl/$apiV1/upload/video';
      final uploadResponse = await multipartRequestVideo(
        uploadUrl,
        videoFile,
        'video',
      );

      if (uploadResponse['error'] == null) {
        final videoUrl = uploadResponse['url'] ?? uploadResponse['fileUrl'];

        final applicationResult = await _submitCompleteApplication(
          projectHash,
          userData,
          videoUrl,
        );

        return applicationResult;
      } else {
        return {'success': false, 'error': uploadResponse['error']};
      }
    } catch (e) {
      debugPrint('Exception in uploadVideo: $e');
      return {'success': false, 'error': 'Failed to upload video'};
    }
  }

  Future<dynamic> submitApplicationWithoutVideo(
    String projectHash,
    Map<String, String> userData,
  ) async {
    return await _submitCompleteApplication(projectHash, userData, null);
  }

  Future<dynamic> _submitCompleteApplication(
    String projectHash,
    Map<String, String> userData,
    String? videoUrl,
  ) async {
    try {
      final url = '$baseUrl/$apiV1/apply/$projectHash';
      final localStorage = LocalStorageService();
      final resumeUrl = await localStorage.getData('resumeUrl');

      final body = {
        'firstName': userData['name']?.split(' ').first ?? '',
        'lastName': userData['name']?.split(' ').skip(1).join(' ') ?? '',
        'email': userData['email'] ?? '',
        'phone': userData['phone'] ?? '',
        if (resumeUrl != null) 'resumeUrl': resumeUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };

      final response = await postRequest(url, body);

      if (response['error'] == null) {
        await localStorage.clearData('resumeUrl');

        return {
          'success': true,
          'message': 'Application submitted successfully',
          'applicationId': response['applicationId'],
        };
      } else {
        debugPrint('Error submitting application: ${response['error']}');
        return {'success': false, 'error': response['error']};
      }
    } catch (e) {
      debugPrint('Exception in _submitCompleteApplication: $e');
      return {'success': false, 'error': 'Failed to submit application'};
    }
  }

  Future<dynamic> getRequest(String url) async {
    try {
      final headers = await addHeaders(isMultiPart: false);
      final response = await _client.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failure in GET $url - Status: ${response.statusCode}');
        final responseBody = json.decode(response.body);
        return {
          'error': responseBody['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': responseBody,
        };
      }
    } catch (e) {
      debugPrint('Error in GET: $url - Exception: $e');
      return {'error': e.toString()};
    }
  }

  Future<dynamic> multipartRequestImage(
    String url,
    File imageFile,
    String fileType,
  ) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final mimeType = lookupMimeType(imageFile.path);
      final mimeTypeParts = mimeType!.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath(
          fileType,
          imageFile.path,
          contentType: mediaType,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);
        return res;
      } else {
        debugPrint(
          'Error in multipart request: $url - Status: ${response.statusCode}',
        );
        final responseBody = await http.Response.fromStream(response);
        return {
          'error': 'Failed to upload image',
          'statusCode': response.statusCode,
          'responseBody': responseBody.body,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request: $url - Exception: $e');
      return {'error': e.toString()};
    }
  }

  Future<dynamic> multipartRequestVideo(
    String url,
    File videoFile,
    String fileType,
  ) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final mimeType = lookupMimeType(videoFile.path);
      final mimeTypeParts = mimeType!.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(
        await http.MultipartFile.fromPath(
          fileType,
          videoFile.path,
          contentType: mediaType,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);
        return res;
      } else {
        debugPrint(
          'Error in multipart request: $url - Status: ${response.statusCode}',
        );
        final responseBody = await http.Response.fromStream(response);
        return {
          'error': 'Failed to upload video',
          'statusCode': response.statusCode,
          'responseBody': responseBody.body,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request: $url - Exception: $e');
      return {'error': e.toString()};
    }
  }

  Future<dynamic> multipartRequestFile(
    String url,
    File file,
    String fileType,
  ) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      final mimeType = lookupMimeType(file.path);
      if (mimeType == null) {
        debugPrint('Error: Could not determine the MIME type.');
        return {'error': 'Could not determine file type'};
      }
      final mimeTypeParts = mimeType.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      request.files.add(
        await http.MultipartFile.fromPath(
          fileType,
          file.path,
          contentType: mediaType,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);
        return res;
      } else {
        debugPrint(
          'Error in multipart request API call: $url - Status: ${response.statusCode}',
        );
        final responseBody = await http.Response.fromStream(response);
        return {
          'error': 'Failed to upload file',
          'statusCode': response.statusCode,
          'responseBody': responseBody.body,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request code: $url - Exception: $e');
      return {'error': e.toString()};
    }
  }

  Future<dynamic> postRequest(String url, Map<String, dynamic> body) async {
    try {
      final headers = await addHeaders();
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        debugPrint('Failure in POST $url - Status: ${response.statusCode}');
        final responseBody = json.decode(response.body);
        return {
          'error': responseBody['message'] ?? 'Request failed',
          'statusCode': response.statusCode,
          'data': responseBody,
        };
      }
    } catch (e) {
      debugPrint('Error in POST $url - Exception: $e');
      return {'error': e.toString()};
    }
  }

  Future<Map<String, String>> addHeaders({
    isMultiPart = false,
    isStream = false,
  }) async {
    final localStorage = LocalStorageService();
    final token = await localStorage.getData('token');
    if (token != null) {
      return isMultiPart
          ? (isStream)
                ? {
                    'Authorization': 'Bearer $token',
                    'authorization': 'Bearer $token',
                    'Content-Type': 'video/webm',
                  }
                : {
                    'Authorization': 'Bearer $token',
                    'authorization': 'Bearer $token',
                  }
          : {
              'Authorization': 'Bearer $token',
              'authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            };
    }
    return isMultiPart
        ? {
            // Don't set Content-Type for multipart, let HTTP client handle it
          }
        : {'Content-Type': 'application/json'};
  }

  void showErrorDialog(
    BuildContext context,
    String message,
    Function? callback, {
    String? title,
  }) {
    ErrorBlackDialogue.showSnackBar(context, title, message);
  }
}
