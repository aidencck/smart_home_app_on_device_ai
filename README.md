# 🏠 Smart Home On-Device AI Agent

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2.svg?logo=dart)
![llama.cpp](https://img.shields.io/badge/llama.cpp-Edge_AI-orange.svg)
![Isar DB](https://img.shields.io/badge/Isar-3.1-green.svg)
![License](https://img.shields.io/badge/License-MIT-success.svg)

A next-generation Smart Home application featuring a **purely on-device, zero-latency, and privacy-first AI Agent**. Powered by `llama.cpp` through Dart FFI and a lightweight local RAG (Retrieval-Augmented Generation) system.

---

## ✨ Core Features

*   **🧠 Pure On-Device Inference**: Runs LLMs (Gemma-2B/Qwen-1.5B) entirely locally on your phone using `llama.cpp`. No cloud dependencies, no network latency, and absolute privacy.
*   **🎯 Zero-Hallucination Hardware Control**: Utilizes dynamic **GBNF (GGML BNF) grammar trees** to strictly constrain the AI's output to valid JSON formats and existing device IDs. It guarantees 100% deterministic parsing for IoT control.
*   **📚 Edge RAG (Retrieval-Augmented Generation)**: Employs `Isar` object database to store user behavior logs locally. The AI can dynamically retrieve these logs to answer queries like *"Did anyone open the door today?"* without ever sending data to the cloud.
*   **⚡ Isolate-Driven Architecture**: Heavy C++ model loading and inference are isolated in Dart background threads, ensuring the Flutter UI maintains a buttery-smooth 60fps.
*   **🔍 Transparent AI "Chain of Thought"**: The UI visualizes the AI's thought process (Intent Routing -> RAG Context -> Grammar Generation) and displays clear "Before vs. After" state changes for executed commands.

## 🏗 Architecture Overview

The project is strictly decoupled into two layers: the UI application and the independent AI package (`on_device_agent`).

```text
lib/ (Flutter UI)
 ├── main.dart (App Entry & AgentScreen)
 └── models/ & services/ (Mock IoT Device Management)

packages/on_device_agent/ (Core AI Logic)
 ├── lib/src/
 │    ├── engine/        # LlamaCppEngine (FFI bindings) & MockEngine
 │    ├── context/       # Prompt builder & Dynamic GBNF generator
 │    └── executor/      # JSON Parser, Isar DB RAG retrieval, Guardrails
 └── ios/Classes/llama_cpp_src/ # llama.cpp C++ source code submodule
```

## 🚀 Getting Started

### Prerequisites
*   Flutter SDK `3.x`
*   Dart SDK `3.x`
*   (For iOS/macOS) Xcode and CocoaPods
*   (For Android) Android Studio & NDK

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/smart_home_app_on_device_ai.git
   cd smart_home_app_on_device_ai
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Isar database schemas:**
   ```bash
   cd packages/on_device_agent
   flutter pub run build_runner build
   cd ../..
   ```

4. **Run the App:**
   ```bash
   # Run in debug mode (Includes Performance Metrics UI)
   flutter run
   ```
   > **Note:** By default, running on Web or Simulator will use the `LlamaCppEngineMock` (fallback engine) since compiling C++ LLM inference requires real device hardware acceleration (Metal/Vulkan).

## 🛠 Advanced: Running Real LLMs on Device

To use real on-device inference instead of the mock engine:
1. Download a highly quantized `.gguf` model (e.g., `gemma-2b-it-q4_k_m.gguf`).
2. Place it in the `assets/models/` directory.
3. Update the initialization path in `main.dart`:
   ```dart
   await _agent.initialize(modelPath: "assets/models/your_model.gguf");
   ```
4. Ensure hardware acceleration is enabled in native builds (e.g., `GGML_METAL=1` for iOS).

## 📝 Debugging & Performance Tracking

The application includes a built-in profiler available only in `kDebugMode`. When you send a command to the AI, it will output a dedicated metrics panel showing:
*   **Inference Time (ms)**: Pure C++ execution time.
*   **Total Latency (ms)**: From tapping "Send" to UI rendering.
*   **Throughput (Tokens/s)**: The generation speed of the LLM on your hardware.

## 🤝 Contributing

We welcome contributions! Please see our [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
