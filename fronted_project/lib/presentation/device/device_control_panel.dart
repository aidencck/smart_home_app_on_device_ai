import 'dart:async';
import 'package:flutter/material.dart';

/// 模拟设备物模型 (TSL) 数据结构
class DeviceTsl {
  final String deviceId;
  final String deviceType; // 'light' or 'bed'
  final Map<String, dynamic> properties;

  DeviceTsl({
    required this.deviceId,
    required this.deviceType,
    required this.properties,
  });
}

class DeviceControlPanel extends StatefulWidget {
  final DeviceTsl device;

  const DeviceControlPanel({Key? key, required this.device}) : super(key: key);

  @override
  State<DeviceControlPanel> createState() => _DeviceControlPanelState();
}

class _DeviceControlPanelState extends State<DeviceControlPanel> {
  late Map<String, dynamic> _currentProperties;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // 初始化本地状态
    _currentProperties = Map<String, dynamic>.from(widget.device.properties);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// 模拟调用 Device API 并带防抖处理
  void _sendControlCommand(String propertyKey, dynamic value) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // 设置 500ms 的防抖时长
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // 模拟 API 调用
      debugPrint('🚀 [Device API] 发送控制指令: 设备=${widget.device.deviceId}, 属性=$propertyKey, 值=$value');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已向 ${widget.device.deviceType} 发送指令: $propertyKey = $value'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  /// 构建 Switch 开关组件
  Widget _buildSwitch(String title, String propertyKey) {
    final bool value = _currentProperties[propertyKey] ?? false;
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (newValue) {
        setState(() {
          _currentProperties[propertyKey] = newValue;
        });
        // 开关直接发送指令，但也复用了防抖逻辑
        _sendControlCommand(propertyKey, newValue);
      },
    );
  }

  /// 构建 Slider 滑动条组件 (带 onChangeEnd 防抖触发)
  Widget _buildSlider(String title, String propertyKey, double min, double max, int divisions, String unit) {
    final double value = (_currentProperties[propertyKey] ?? min).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          onChanged: (newValue) {
            // 仅更新本地 UI 状态，不发送 API 指令
            setState(() {
              _currentProperties[propertyKey] = newValue;
            });
          },
          onChangeEnd: (newValue) {
            // 滑动停止时触发防抖发送指令
            _sendControlCommand(propertyKey, newValue);
          },
        ),
      ],
    );
  }

  /// 智能灯 (light) 控制面板
  Widget _buildLightPanel() {
    return Column(
      children: [
        _buildSwitch('电源开关', 'power'),
        const Divider(),
        _buildSlider('亮度', 'brightness', 0.0, 100.0, 100, '%'),
        const Divider(),
        _buildSlider('色温', 'colorTemperature', 2700.0, 6500.0, 380, 'K'),
      ],
    );
  }

  /// 智能床 (bed) 控制面板
  Widget _buildBedPanel() {
    return Column(
      children: [
        _buildSwitch('床垫加热', 'heating'),
        const Divider(),
        _buildSlider('头部高度', 'headHeight', 0.0, 60.0, 60, '°'),
        const Divider(),
        _buildSlider('脚部高度', 'footHeight', 0.0, 60.0, 60, '°'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget panelContent;
    
    // 根据设备类型动态解析并生成对应的控制面板
    switch (widget.device.deviceType) {
      case 'light':
        panelContent = _buildLightPanel();
        break;
      case 'bed':
        panelContent = _buildBedPanel();
        break;
      default:
        panelContent = const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('不支持的设备类型'),
          ),
        );
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '设备控制面板 - ${widget.device.deviceType.toUpperCase()}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            panelContent,
          ],
        ),
      ),
    );
  }
}
