import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:profesh_forms/components/dialogues.dart';
import 'package:profesh_forms/services/local_storage.dart';

class ApiService {
  final _client = http.Client();
  Future<dynamic> getJobDetails(String jobId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    return {
      'success': true,
      'title': 'Senior Flutter Developer',
      'company': 'Profesh Technologies',
      'description': 'We are looking for an experienced Flutter developer to join our dynamic team. You will be responsible for developing high-quality mobile applications using Flutter framework. The ideal candidate should have strong knowledge of Dart programming language, state management solutions like Provider or Bloc, and experience with RESTful APIs integration.',
      'location': 'Bengaluru, Karnataka',
      'type': 'Full-time',
      'logo': 'https://example.com/logo.png',
      'videoUrl': '',
      'jdPdf':'',
    };
  }
  Future<dynamic> checkApplicationStatus(String jobId, String email, String phone) async {
    await Future.delayed(const Duration(seconds: 1));
    final alreadyApplied = DateTime.now().millisecond % 3 == 0;
    
    return {
      'success': true,
      'alreadyApplied': alreadyApplied,
      'message': alreadyApplied 
          ? 'You have already applied for this position'
          : 'You can proceed with the application'
    };
  }
  Future<dynamic> uploadCV(String jobId, File cvFile, Map<String, String> userData) async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'success': true,
      'message': 'CV uploaded successfully',
      'cvUrl': 'https://example.com/cv/${DateTime.now().millisecondsSinceEpoch}.pdf'
    };
  }
  Future<dynamic> uploadVideo(String jobId, File videoFile, Map<String, String> userData) async {
    await Future.delayed(const Duration(seconds: 5));
    
    return {
      'success': true,
      'message': 'Video uploaded successfully',
      'videoUrl': 'https://example.com/video/${DateTime.now().millisecondsSinceEpoch}.mp4'
    };
  }
  Future<dynamic> getRequest(String url) async {
    try {
      final headers = await addHeaders(isMultiPart: false);
      final response = await _client.get(
        Uri.parse(url),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('Failure in GET $url');
        return {
          'error': json.decode(response.body)['message'],
          'statusCode': response.statusCode,
          'data': json.decode(response.body),
        };
      }
    } catch (e) {
      debugPrint('Error in GET: /$url');
      return {
        'error': e.toString(),
      };
    }
  }

  Future<dynamic> multipartRequestImage(
      String url, File imageFile, String fileType) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final mimeType = lookupMimeType(imageFile!.path);
      final mimeTypeParts = mimeType!.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath(
          fileType, imageFile!.path,
          contentType: mediaType));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);

        return res;
      } else {
        debugPrint('Error in multipart request: $url');
        return {
          'error': 'Failed to upload image',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request: $url');

      return {
        'error': e.toString(),
      };
    }
  }

  Future<dynamic> multipartRequestVideo(
      String url, File videoFile, String fileType) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final mimeType = lookupMimeType(videoFile.path);
      final mimeTypeParts = mimeType!.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      request.files.add(await http.MultipartFile.fromPath(
          fileType, videoFile.path,
          contentType: mediaType));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await http.Response.fromStream(response);
        final res = json.decode(responseBody.body);

        return res;
      } else {
        debugPrint('Error in multipart request: $url');
        return {
          'error': 'Failed to upload video',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      debugPrint('Error in multipart request: $url');

      return {
        'error': e.toString(),
      };
    }
  }

  Future<dynamic> multipartRequestFile(
      String url, File file, String fileType) async {
    try {
      final headers = await addHeaders(isMultiPart: true);
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);
      final mimeType = lookupMimeType(file!.path);
      if (mimeType == null) {
        debugPrint('Err Could not determine the MIME type.');
        return;
      }
      final mimeTypeParts = mimeType.split('/');
      final mediaType = MediaType(mimeTypeParts[0], mimeTypeParts[1]);
      request.files.add(await http.MultipartFile.fromPath(
        fileType,
        file!.path,
        contentType: mediaType,
      ));

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

      return {
        'error': e.toString(),
      };
    }
  }

  Future<dynamic> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
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
        debugPrint('Failure in POST $url');
        return {
          'error': json.decode(response.body)['message'],
          'statusCode': response.statusCode,
          'data': json.decode(response.body),
        };
      }
    } catch (e) {
      debugPrint('Error in POST $url');
      return {
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, String>> addHeaders(
      {isMultiPart = false, isStream = false}) async {
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
                  'Content-Type': 'multipart/form-data',
                }
          : {
              'Authorization': 'Bearer $token',
              'authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  void showErrorDialog(BuildContext context, String message, Function? callback,
      {String? title}) {
    ErrorBlackDialogue.showSnackBar(context, title, message);
  }
}
