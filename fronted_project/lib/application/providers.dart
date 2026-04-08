import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/virtual_device_service.dart';
import 'device_manager.dart';
import 'agent_manager.dart';
import 'system_state_machine.dart';

// Providers for services
final deviceServiceProvider = Provider((ref) => VirtualDeviceService());

// Provider for SystemStateMachine
final systemStateMachineProvider = ChangeNotifierProvider<SystemStateMachine>((ref) {
  return SystemStateMachine();
});

// Provider for DeviceManager
final deviceManagerProvider = ChangeNotifierProvider<DeviceManager>((ref) {
  final service = ref.watch(deviceServiceProvider);
  final stateMachine = ref.watch(systemStateMachineProvider);
  return DeviceManager(service, stateMachine);
});

// Provider for AgentManager
final agentManagerProvider = ChangeNotifierProvider<AgentManager>((ref) {
  final deviceManager = ref.read(deviceManagerProvider);
  return AgentManager(deviceManager);
});
