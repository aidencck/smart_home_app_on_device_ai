# 📱 智能家居项目：移动端 App 应用商店自动化发布方案 (App Store & Google Play)

> **Status**: Recommendation | **Scope**: Mobile DevOps / CI/CD | **Update**: 2026-04-14

针对您提出的“是否能直接发布到应用商店”的问题，经评估，**目前流水线（Pipeline）仅覆盖了代码质量检查与单元测试，尚未具备自动发布（CD）到 App Store 和 Google Play 的能力。**

要实现这一功能，我们需要引入专业的移动端自动化工具（如 **Fastlane**）并配置复杂的证书/密钥管理。以下是深度实施方案：

---

## 一、 核心缺失项与前置条件

要实现“一键发布”，必须解决以下关键技术债：

### 1. 签名与证书管理 (Code Signing)
*   **iOS**: 需要配置 Apple Distribution 证书、Provisioning Profiles，并使用 `App Store Connect API` 密钥进行自动化认证。
*   **Android**: 需要生成 `.jks` 签名文件，并获取 Google Play Console 的 `Service Account` JSON 密钥。

### 2. 自动化工具链 (Fastlane)
*   目前项目中缺失 `fastlane` 目录。这是业界标准的移动端发布自动化工具，用于处理屏幕截图、元数据上传、IPA/APK 构建及上传。

### 3. 构建环境
*   **iOS 构建**: 必须在 **macOS** 运行环境（`runs-on: macos-latest`）下执行，这比 Linux 环境成本更高。
*   **Android 构建**: 可在 Linux 环境下完成。

---

## 二、 自动化发布流水线架构 (Mobile CD)

建议将现有的 [flutter_ci.yml](file:///.github/workflows/flutter_ci.yml) 升级为具备发布能力的流水线，采用以下分级策略：

### 1. 内部测试版 (Internal Testing / TestFlight)
*   **触发条件**: 合并至 `develop` 或 `release/*` 分支。
*   **目标**: 自动上传至 TestFlight (iOS) 和 Google Play 内部测试轨道 (Android)。
*   **价值**: 供 QA 和团队内部快速验证。

### 2. 生产正式版 (Production)
*   **触发条件**: 创建带有版本号的 Git Tag (如 `v1.2.0`)。
*   **逻辑**: 
    1.  运行全量回归测试。
    2.  调用 Fastlane 执行 `release` 打包。
    3.  上传至 App Store Connect (等待审核) 和 Google Play 生产轨道。
    4.  **人工确认**: 在 GitHub Actions 中设置手动点击按钮才触发最后的发布步骤。

---

## 三、 技术实现路径 (Implementation)

### 1. 初始化 Fastlane
在 `fronted_project/ios` 和 `fronted_project/android` 下分别初始化 Fastlane：
*   使用 `match` 管理 iOS 证书（推荐存储在私有 Git 仓库）。
*   使用 `supply` 管理 Google Play 商店信息。

### 2. 密钥注入 (GitHub Secrets)
严禁在代码库中存储任何密钥！必须通过 GitHub Secrets 注入：
*   `APP_STORE_CONNECT_KEY_CONTENT`: iOS 发布密钥。
*   `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`: Android 发布密钥。
*   `ANDROID_KEYSTORE_BASE64`: 经过 Base64 编码的签名文件。

### 3. 流水线示例 (GitHub Actions)
```yaml
jobs:
  deploy-ios:
    name: Build & Deploy iOS
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Fastlane
        run: gem install fastlane
      - name: Run Fastlane (TestFlight)
        run: bundle exec fastlane ios beta
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          APP_STORE_CONNECT_API_KEY: ${{ secrets.APP_STORE_CONNECT_API_KEY }}

  deploy-android:
    name: Build & Deploy Android
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build & Upload to Play Store
        run: bundle exec fastlane android beta
        env:
          GOOGLE_PLAY_JSON: ${{ secrets.GOOGLE_PLAY_SERVICE_ACCOUNT_JSON }}
```

---

## 四、 2026 年最新趋势：App 发布的“热更新”与“影子环境”

*   **热更新 (CodePush)**: 对于 Flutter 修复类的小改动，可以集成热更新技术，跳过应用商店漫长的审核期，实现分钟级发布。
*   **多环节分离**: 在应用商店内也应区分 `alpha`, `beta`, `production` 轨道，确保从流水线出来的包经过层层过滤。

---

## 五、 总结与建议

**可以直接发布，但需要补充以下工作：**
1.  **引入 Fastlane**: 作为跨平台发布的“翻译官”。
2.  **配置签名**: 准备好 Apple 和 Google 的开发者账号及密钥。
3.  **升级 Actions**: 引入 `macos-latest` 运行节点用于编译 iOS。

如果您需要，我可以为您起草一份具体的 `fastlane` 配置文件模板。
