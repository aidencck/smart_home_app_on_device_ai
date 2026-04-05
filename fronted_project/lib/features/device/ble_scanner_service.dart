import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleScannerService {
  static final BleScannerService _instance = BleScannerService._internal();
  factory BleScannerService() => _instance;
  BleScannerService._internal();

  final StreamController<List<ScanResult>> _scanResultsController = StreamController<List<ScanResult>>.broadcast();
  Stream<List<ScanResult>> get scanResults => _scanResultsController.stream;

  List<ScanResult> _discoveredDevices = [];

  /// 开始扫描附近的蓝牙设备
  Future<void> startScan({Duration timeout = const Duration(seconds: 10)}) async {
    _discoveredDevices.clear();
    _scanResultsController.add(_discoveredDevices);

    // 监听扫描结果
    var subscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // 过滤 Luma AI 特征的设备
        if (_isLumaAiDevice(r)) {
          // 避免重复添加
          if (!_discoveredDevices.any((d) => d.device.remoteId == r.device.remoteId)) {
            _discoveredDevices.add(r);
            _scanResultsController.add(_discoveredDevices);
          }
        }
      }
    });

    // 启动扫描
    await FlutterBluePlus.startScan(timeout: timeout);
    
    // 等待扫描完成并取消订阅
    await Future.delayed(timeout);
    await subscription.cancel();
  }

  /// 停止扫描
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// 识别是否为 Luma AI 设备
  bool _isLumaAiDevice(ScanResult result) {
    // 优先使用 advName，如果没有则使用 platformName
    final deviceName = result.device.advName.isNotEmpty 
        ? result.device.advName 
        : result.device.platformName;
        
    // 通过名称过滤包含 'luma' 或 'luma ai' 的设备
    if (deviceName.toLowerCase().contains('luma')) {
      return true;
    }
    
    // 也可以在此处添加特定 Service UUID 的过滤逻辑
    // 例如: result.advertisementData.serviceUuids.contains(Guid("YOUR_SERVICE_UUID"))
    
    return false;
  }

  /// 解析设备的 MAC 地址
  String getMacAddress(ScanResult result) {
    // 在 Android 上，remoteId 通常表示 MAC 地址
    // 在 iOS 上，由于隐私限制，它是一个 UUID。如果硬件支持在广播包中包含 MAC 地址，则需要解析 advertisementData。
    return result.device.remoteId.str;
  }

  void dispose() {
    _scanResultsController.close();
  }
}
