# Contributing to Smart Home On-Device AI Agent

First off, thank you for considering contributing to this project! It's people like you that make open-source communities great.

## 🧠 Core Philosophy
This project is dedicated to exploring **On-Device AI** for Smart Homes. All feature proposals and pull requests should align with our core principles:
1. **Privacy First**: No user data or behavior logs should ever leave the device.
2. **Zero-Latency**: Inference and execution should be heavily optimized. Blocking the UI thread is strictly prohibited.
3. **Deterministic Output**: AI hardware control must be reliable. We rely on Grammar-constrained decoding (GBNF) rather than prompt engineering to ensure JSON validity.

## 🛠 Development Setup

1. **Flutter Setup**: Ensure you are using the latest stable channel of Flutter (>= 3.x).
2. **C++ & llama.cpp**: The core inference engine relies on `llama.cpp`. If you are modifying the C++ bindings in `model_forge/inference/on_device_agent`, make sure you have CMake and Ninja installed.
3. **Code Generation**: We use `build_runner` for Isar databases. If you modify any model inside `lib/src/models/`, you MUST run:
   ```bash
   cd model_forge/inference/on_device_agent
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## 📝 Pull Request Process

1. **Fork the repo** and create your branch from `main`.
2. **Write tests** if you are adding new features (especially parsing logic or intent routing).
3. **Run `flutter analyze`** and ensure there are no warnings or errors.
4. **Update documentation** (README or inline docs) if you change any public APIs or architecture behaviors.
5. **Issue a PR** with a clear title and description of your changes. If your PR changes the UI, please include screenshots or GIFs.

## 🐛 Bug Reports
When filing an issue, please include:
- Your device model and OS version.
- Whether you are using the `LlamaCppEngineMock` or a real `.gguf` model.
- Steps to reproduce the bug.
- Any relevant logs (especially if the C++ engine crashed).

## 🚀 Future Roadmap
We are actively looking for help in the following areas:
- [ ] Hardware acceleration support (Metal for iOS, Vulkan for Android) via FFI.
- [ ] Automated model downloading and OTA (Over-The-Air) updates.
- [ ] Integration with system-level voice assistants (Siri/Google Assistant).
- [ ] Support for Multi-modal models (Vision/Speech).