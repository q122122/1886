import 'package:flutter/material.dart';
import 'package:nba_prediction_app/services/prediction_service.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于系统'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSystemOverview(),
            const SizedBox(height: 24),
            _buildPredictionMethods(),
            const SizedBox(height: 24),
            _buildTechnicalArchitecture(),
            const SizedBox(height: 24),
            _buildDisclaimerSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '系统概述',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'NBA比赛预测系统是一个基于多维度数据分析和机器学习建模的预测平台，旨在提供高准确率的NBA比赛胜负、总分和让分盘预测。系统融合了运动科学、金融数学和AI技术，通过五个核心预测层面实现精准预测。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionMethods() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '预测方法',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '系统的预测依据可分为五个核心层面：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildPredictionLayer(
              '1. 基础统计学预测 (35%权重)',
              '球队近10场攻防效率值、球员PER值、主场优势量化公式等',
              Colors.blue,
            ),
            _buildPredictionLayer(
              '2. 动态系统建模 (25%权重)',
              'NBA定制Elo公式、马尔可夫链状态转移',
              Colors.green,
            ),
            _buildPredictionLayer(
              '3. 机器学习特征工程 (30%权重)',
              'XGBoost模型、LSTM网络、贝叶斯岭回归',
              Colors.orange,
            ),
            _buildPredictionLayer(
              '4. 市场信号整合 (8%权重)',
              '赛前24/12/3小时赔率变化、社交舆情分析',
              Colors.purple,
            ),
            _buildPredictionLayer(
              '5. 不确定性量化 (2%权重)',
              '蒙特卡洛模拟、贝叶斯更新机制',
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionLayer(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalArchitecture() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '技术架构',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '系统采用现代化的技术栈：',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 8),
            Text('• 编程语言: Python 3.10'),
            Text('• 数据处理: Pandas, NumPy, SciPy'),
            Text('• 机器学习: Scikit-learn, XGBoost, TensorFlow/Keras'),
            Text('• Web框架: FastAPI/Flutter'),
            Text('• 数据库: SQLite (移动版) / PostgreSQL (服务器版)'),
            SizedBox(height: 12),
            Text(
              '移动应用使用Flutter框架开发，通过API与后端预测服务通信，确保预测结果与原系统保持一致。',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '免责声明',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '本预测系统仅供技术研究参考，不构成投注建议。系统预测结果基于历史数据和算法模型，无法保证100%准确。用户应自行承担使用本系统信息进行决策的风险。',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
