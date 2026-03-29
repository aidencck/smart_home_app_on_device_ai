import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class ModelDownloader {
  /// 下载模型并校验 MD5
  /// [modelUrl] 模型的远程下载地址
  /// [savePath] 本地保存路径
  /// [expectedMd5] 预期的 MD5 值 (可选，如果提供则会在下载后校验)
  /// [onProgress] 进度回调函数
  static Future<bool> downloadModel({
    required String modelUrl,
    required String savePath,
    String? expectedMd5,
    Function(double progress)? onProgress,
  }) async {
    try {
      final file = File(savePath);
      if (await file.exists()) {
        log("模型文件已存在，开始校验 MD5...");
        if (expectedMd5 != null) {
          final isMd5Match = await _verifyMd5(file, expectedMd5);
          if (isMd5Match) {
            log("MD5 校验通过，跳过下载。");
            if (onProgress != null) onProgress(1.0);
            return true;
          } else {
            log("MD5 校验失败，文件可能已损坏，准备重新下载。");
            await file.delete();
          }
        } else {
          log("未提供预期 MD5，假定现有文件有效，跳过下载。");
          if (onProgress != null) onProgress(1.0);
          return true;
        }
      }

      log("开始下载模型文件: $modelUrl");
      final request = http.Request('GET', Uri.parse(modelUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception("下载失败，状态码: ${response.statusCode}");
      }

      final contentLength = response.contentLength ?? 0;
      int bytesDownloaded = 0;
      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        bytesDownloaded += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(bytesDownloaded.toDouble() / contentLength.toDouble());
        }
      }
      
      await sink.flush();
      await sink.close();
      
      log("模型下载完成，保存至: $savePath");

      // 下载完成后校验 MD5
      if (expectedMd5 != null) {
        log("正在进行下载后 MD5 校验...");
        final isMd5Match = await _verifyMd5(file, expectedMd5);
        if (!isMd5Match) {
          log("下载后 MD5 校验失败！文件可能损坏或被篡改。");
          await file.delete();
          return false;
        }
        log("下载后 MD5 校验通过！");
      }

      return true;
    } catch (e) {
      log("模型下载过程中发生错误: $e");
      return false;
    }
  }

  /// 计算文件的 MD5 值并进行比对
  static Future<bool> _verifyMd5(File file, String expectedMd5) async {
    try {
      // 使用流式读取计算大文件的 MD5，避免内存溢出
      final stream = file.openRead();
      final hash = await md5.bind(stream).first;
      final actualMd5 = hash.toString();
      log("文件 MD5: $actualMd5, 预期 MD5: $expectedMd5");
      return actualMd5.toLowerCase() == expectedMd5.toLowerCase();
    } catch (e) {
      log("计算 MD5 异常: $e");
      return false;
    }
  }
}
