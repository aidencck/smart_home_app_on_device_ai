import 'package:flutter/material.dart';
import '../../theme/figma_colors.dart';

class AiAgentDemoPage extends StatefulWidget {
  const AiAgentDemoPage({super.key});

  @override
  State<AiAgentDemoPage> createState() => _AiAgentDemoPageState();
}

class _AiAgentDemoPageState extends State<AiAgentDemoPage> {
  bool _isExecuting = true;
  bool _showApproval = true;
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(context),
          if (_isSearching) ...[
            const SizedBox(height: 16),
            _buildSearchResults(context),
          ] else ...[
            const SizedBox(height: 24),
            _buildMultiModalInput(context),
            const SizedBox(height: 24),
            if (_isExecuting) _buildExecutionTrace(context),
            const SizedBox(height: 24),
            if (_showApproval) _buildApprovalNotification(context),
            const SizedBox(height: 24),
            _buildArtifacts(context),
          ]
        ],
      ),
    );
  }

  // 构建统一风格的卡片容器
  Widget _buildCardContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB), // 浅灰色卡片背景，与截图一致
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB), // 搜索框也使用统一浅灰色
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
        onChanged: (value) {
          setState(() {
            _isSearching = value.trim().isNotEmpty;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Color(0xFF6B7280)),
          hintText: '搜索动作或设备...',
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    return _buildCardContainer(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('推荐动作', style: TextStyle(color: Color(0xFF1F2937), fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          _buildStyleListItem(
            icon: Icons.play_arrow,
            iconColor: const Color(0xFF1A73E8),
            iconBgColor: const Color(0xFFD1E4FF),
            title: '开启客厅空调制冷',
          ),
          _buildStyleListItem(
            icon: Icons.build,
            iconColor: const Color(0xFFF59E0B),
            iconBgColor: const Color(0xFFFEF3C7),
            title: '运行 "排查故障" 工作流',
          ),
        ],
      ),
    );
  }

  Widget _buildMultiModalInput(BuildContext context) {
    return _buildCardContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '有什么我可以帮您的？',
            style: TextStyle(
              color: Color(0xFF1F2937), 
              fontSize: 20, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInputButton(Icons.mic, '语音指令', const Color(0xFF1A73E8), const Color(0xFFD1E4FF)),
              _buildInputButton(Icons.keyboard, '文本输入', const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
              _buildInputButton(Icons.camera_alt, '环境识别', const Color(0xFF10B981), const Color(0xFFD1FAE5)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInputButton(IconData icon, String label, Color iconColor, Color bgColor) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 12),
        Text(
          label, 
          style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, fontWeight: FontWeight.w500)
        ),
      ],
    );
  }

  Widget _buildExecutionTrace(BuildContext context) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1E4FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.track_changes, color: Color(0xFF1A73E8), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('目标: "解除大门安防"', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildTraceStep(Icons.check_circle, '识别意图: 安防控制', const Color(0xFF10B981)),
          _buildTraceStep(Icons.check_circle, '调用工具: 门锁控制 API', const Color(0xFF10B981)),
          _buildTraceStep(Icons.warning, '权限请求: 触发 L3 级安全策略', const Color(0xFFF59E0B)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('正在尝试解除安防，请验证指纹', style: TextStyle(color: Color(0xFF1F2937), fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () => setState(() => _isExecuting = false),
                          child: const Text('取消', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1E4FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextButton(
                          onPressed: () => setState(() => _isExecuting = false),
                          child: const Text('授权', style: TextStyle(color: Color(0xFF1A73E8), fontSize: 14, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTraceStep(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 15))),
        ],
      ),
    );
  }

  Widget _buildApprovalNotification(BuildContext context) {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.crisis_alert, color: Color(0xFFEF4444), size: 20),
              ),
              const SizedBox(width: 12),
              const Text('安全提醒', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('发现异常闯入，是否立即报警？', style: TextStyle(color: Color(0xFF4B5563), fontSize: 16)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _showApproval = false),
                child: const Text('忽略', style: TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
              ),
              const SizedBox(width: 16),
              Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextButton(
                  onPressed: () => setState(() => _showApproval = false),
                  child: const Text('立即报警', style: TextStyle(color: Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildArtifacts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('最近沉淀产物', style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        _buildStyleListItem(
          icon: Icons.rule,
          iconColor: const Color(0xFF8B5CF6),
          iconBgColor: const Color(0xFFEDE9FE),
          title: '自动化规则：下雨自动关窗',
          subtitle: '刚刚生成',
        ),
        const SizedBox(height: 12),
        _buildStyleListItem(
          icon: Icons.bar_chart,
          iconColor: const Color(0xFF10B981),
          iconBgColor: const Color(0xFFD1FAE5),
          title: '家庭能耗周报',
          subtitle: '生成于昨天',
        ),
      ],
    );
  }

  // 统一提取的列表项组件，完全还原截图中的圆角、灰色背景、左侧大圆角图标、右侧药丸按钮风格
  Widget _buildStyleListItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFF1F2937), fontSize: 17, fontWeight: FontWeight.bold),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  ),
                ]
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFDDE4FF), // 截图右侧按钮的浅蓝色
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              '查看',
              style: TextStyle(color: Color(0xFF4A65A8), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
