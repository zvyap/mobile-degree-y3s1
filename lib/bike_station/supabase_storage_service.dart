import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Converts an image file or Uint8List bytes into a WebP byte stream.
  Future<Uint8List?> convertToWebp(
      dynamic imageInput, {
        int quality = 80,
      }) async {
    try {
      Uint8List inputBytes;

      if (imageInput is File) {
        inputBytes = await imageInput.readAsBytes();
      } else if (imageInput is Uint8List) {
        inputBytes = imageInput;
      } else if (imageInput is String) {
        inputBytes = await File(imageInput).readAsBytes();
      } else {
        throw ArgumentError('Input must be a File, Uint8List, or File Path String.');
      }

      final Uint8List webpBytes = await FlutterImageCompress.compressWithList(
        inputBytes,
        format: CompressFormat.webp,
        quality: quality,
      );

      return webpBytes;
    } catch (e) {
      debugPrint('WebP Conversion Error: $e');
      return null;
    }
  }

  /// Converts the given image to WebP and uploads it to Supabase Storage.
  /// Returns the public download URL of the uploaded image.
  Future<String?> uploadWebpImage({
    required dynamic imageInput,
    required String bucketName,
    String folderPath = '',
    int quality = 80,
    String? customFileName,
  }) async {
    try {
      // 1. Convert image to WebP format
      final Uint8List? webpData = await convertToWebp(imageInput, quality: quality);
      if (webpData == null) {
        throw Exception("Failed to convert image to WebP format.");
      }

      // 2. Generate unique WebP file name
      final String fileName = customFileName ?? 'img_${DateTime.now().millisecondsSinceEpoch}.webp';
      final String fullPath = folderPath.isEmpty ? fileName : '$folderPath/$fileName';

      // 3. Upload binary to Supabase Storage
      await _supabase.storage.from(bucketName).uploadBinary(
        fullPath,
        webpData,
        fileOptions: const FileOptions(
          contentType: 'image/webp',
          upsert: true,
        ),
      );

      // 4. Return Public Download URL
      return _supabase.storage.from(bucketName).getPublicUrl(fullPath);
    } catch (e) {
      debugPrint('SupabaseStorageService Upload Error: $e');
      rethrow;
    }
  }

  /// Removes an image from Supabase Storage given its path or full public URL.
  Future<void> deleteImage({
    required String bucketName,
    required String pathOrUrl,
  }) async {
    try {
      String storagePath = pathOrUrl;

      // Extract storage path if full public URL is passed
      if (pathOrUrl.startsWith('http')) {
        final Uri uri = Uri.parse(pathOrUrl);
        final List<String> segments = uri.pathSegments;
        final int bucketIndex = segments.indexOf(bucketName);
        if (bucketIndex != -1 && bucketIndex < segments.length - 1) {
          storagePath = segments.sublist(bucketIndex + 1).join('/');
        }
      }

      await _supabase.storage.from(bucketName).remove([storagePath]);
    } catch (e) {
      debugPrint('SupabaseStorageService Delete Error: $e');
      rethrow;
    }
  }
}