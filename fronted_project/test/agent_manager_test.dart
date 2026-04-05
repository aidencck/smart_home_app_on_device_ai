import 'package:smart_home_app/services/virtual_device_service.dart';
import 'package:smart_home_app/application/device_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home_app/application/agent_manager.dart';

void main() {
  group('AgentManager Tests', () {
    late AgentManager agentManager;

    setUp(() {
      
      final virtualDeviceService = VirtualDeviceService();
      final deviceManager = DeviceManager(virtualDeviceService);
      agentManager = AgentManager(deviceManager);

    });

    test('Initializes with default states', () {
      expect(agentManager.isInitialized, false);
      expect(agentManager.isInitializing, false);
      expect(agentManager.isError, false);
      expect(agentManager.chatHistory, isEmpty);
      expect(agentManager.processingSteps, isEmpty);
    });

    test('addProcessingStep adds steps uniquely', () {
      agentManager.addProcessingStep('Step 1');
      expect(agentManager.processingSteps.length, 1);
      expect(agentManager.processingSteps.first, 'Step 1');

      agentManager.addProcessingStep('Step 1');
      expect(agentManager.processingSteps.length, 1); // should not add duplicate
      
      agentManager.addProcessingStep('Step 2');
      expect(agentManager.processingSteps.length, 2);
    });

    test('clearProcessingSteps removes all steps', () {
      agentManager.addProcessingStep('Step 1');
      agentManager.clearProcessingSteps();
      expect(agentManager.processingSteps, isEmpty);
    });

    test('handleSendMessage adds to chatHistory and sets isProcessing', () async {
      // Mock the execution process to avoid real model loading
      // We will just test the synchronous parts of handleSendMessage
      final future = agentManager.handleSendMessage('test message');
      
      expect(agentManager.chatHistory.first['text'], 'test message');
      expect(agentManager.chatHistory.first['role'], 'user');
      expect(agentManager.isProcessing, true);
    });
  });
}
