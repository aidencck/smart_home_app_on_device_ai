// Web 平台的 Dummy 实现
class LlamaCppBindings {
  LlamaCppBindings(String libraryPath);

  dynamic initModel(String modelPath, {bool useMmap = true, bool useMlock = false, int nGpuLayers = 99, int nThreads = 4}) {
    return null;
  }

  String infer(dynamic llamaContext, String prompt, {String? grammarSchema}) {
    return "";
  }

  void freeModel(dynamic llamaContext) {}
}
