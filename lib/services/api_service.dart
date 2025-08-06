import 'dart:io';
import 'package:camera/camera.dart';
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
        final res = response['data'];
        print(res);
        return {
          'success': true,
          'title': res['projectName'] ?? 'Job Position',
          'company': res['companyName'] ?? 'Company',
          'description': res['jobBrief'] ?? 'Job description not available',
          'location': res['location'] ?? 'Location not specified',
          'role': res['jobRole'],
          'type': res['type'] ?? 'Full-time',
          'stipend': res['stipend'],
          'logo': res['companyLogoUrl'],
          'videoUrl': res['videoUrl'] ?? '',
          'jdPdf': res['jdUrl'] ?? '',
          'jdPdfName': res['jdFileName'],
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
    String name,
    String email,
    String phone,
  ) async {
    String firstName, lastName;
    name = name.trim();
    int firstSpaceIndex = name.indexOf(' ');
    if (firstSpaceIndex != -1) {
      firstName = name.substring(0, firstSpaceIndex);
      lastName = name.substring(firstSpaceIndex + 1);
    } else {
      firstName = name;
      lastName = '';
    }
    try {
      final url = '$baseUrl/$apiV1/candidate/public-form-application';
      final body = {
        'projectHash': projectHash,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'countryCode': "+91",
      };

      final response = await postRequest(url, body);

      if (response['error'] == null) {
        final res = response['data'];
        return {
          'success': true,
          'alreadyApplied': res['isApplied'] ?? false,
          'userId': res['userId'],
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

  Future<dynamic> uploadCV(XFile cvFile, Map<String, String> userData) async {
    try {
      final uploadUrl =
          '$serverUrl/$apiV1/user/${userData["userId"]}/public-resume';
      ;
      final uploadResponse = await multipartRequestFile(
        uploadUrl,
        cvFile,
        'resume',
      );

      if (uploadResponse['error'] == null) {
        final resumeUrl = uploadResponse['url'] ?? uploadResponse['fileUrl'];

        await LocalStorageService().setData(
          'resumeUrl',
          'https://example.com/cv/${DateTime.now().millisecondsSinceEpoch}.pdf',
        );

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

  Future<bool> uploadVideo(
    XFile videoFile,
    Map<String, String> userData,
  ) async {
    try {
      if (videoFile.path == null) {
        return false;
      }
      final endpoint =
          '$serverUrl/$apiV1/user/${userData["userId"]}/public-video';
      final fileSize = await videoFile.length();
      final mimeType = 'video/webm';
      final cleanMimeType = mimeType.split(';').first;
      final extension = cleanMimeType.split('/').last;
      final resp = await postRequest(endpoint, {
        "fileName": "${videoFile.path.split('/').last}.$extension",
        "fileSize": fileSize,
      });
      print(resp);
      if (resp['success'] == true) {
        final response = await multipartRequestWebVideo(
          resp["data"],
          videoFile,
          'videoResume',
        );
        if (response['error'] == null) return true;
      }
    } catch (e) {
      print("Error in uploadVideoResume");
      print(e);
    }
    return false;
  }

  Future<dynamic> submitApplicationWithoutVideo(
    String projectHash,
    Map<String, String> userData,
  ) async {
    return await _submitCompleteApplication(projectHash, userData);
  }

  Future<dynamic> _submitCompleteApplication(
    String projectHash,
    Map<String, String> userData,
  ) async {
    try {
      final url = '$baseUrl/$apiV1/project/apply/$projectHash';
      final localStorage = LocalStorageService();
      final resumeUrl = await localStorage.getData('resumeUrl');

      final body = {'userId': userData["userId"]};

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
    XFile file,
    String fileType,
  ) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      final mediaType = MediaType('application', 'pdf');
      final fileBytes = await file.readAsBytes();

      request.files.add(
        await http.MultipartFile.fromBytes(
          fileType,
          fileBytes,
          filename: "${file.path.split('/').last}.pdf",
          contentType: mediaType,
        ),
      );

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);
        return res;
      } else {
        debugPrint('Error in multipart request API call: $url');
        final responseBody = await http.Response.fromStream(response);
        return {
          'error': 'Failed to upload image',
          'statusCode': response.statusCode,
          'responseBody': responseBody.body,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request code: $url');

      return {'error': e.toString()};
    }
  }

  Future<dynamic> multipartRequestWebVideo(
    String url,
    XFile videoFile,
    String fileType,
  ) async {
    try {
      final uri = Uri.parse(url);
      final bodyBytes = await videoFile.readAsBytes();
      var headers = await addHeaders(isMultiPart: true, isStream: true);
      headers['Content-Length'] = bodyBytes.length.toString();
      final response = await http.put(uri, body: await videoFile.readAsBytes());
      if (response.statusCode == 200) {
        final res = {"success": true};
        return res;
      } else {
        print('Error uploading video: ${response.statusCode}');
        return {
          'error': 'Failed to upload video',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Error in multipart request:');
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
