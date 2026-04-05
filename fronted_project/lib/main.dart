import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/app.dart';
import 'application/application.dart';
import 'services/virtual_device_service.dart';

// 全局实例，注入虚拟服务（后续可替换为 RemoteDeviceService）



void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Preload can be handled later
  runApp(const ProviderScope(child: SmartHomeApp()));
}
