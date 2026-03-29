// Web 平台的 Dummy 实现
class LlamaCppBindings {
  LlamaCppBindings(String libraryPath);

  dynamic initModel(String modelPath) {
    return null;
  }

  String infer(dynamic llamaContext, String prompt, {String? grammarSchema}) {
    return "";
  }

  void freeModel(dynamic llamaContext) {}
}
