import 'package:flutter/material.dart';
import 'package:nba_prediction_app/services/prediction_service.dart';
import 'package:fl_chart/fl_chart.dart';

class AccuracyScreen extends StatefulWidget {
  const AccuracyScreen({Key? key}) : super(key: key);

  @override
  State<AccuracyScreen> createState() => _AccuracyScreenState();
}

class _AccuracyScreenState extends State<AccuracyScreen> {
  final PredictionService _predictionService = PredictionService();
  bool _isLoading = true;
  Map<String, dynamic> _accuracyData = {};

  @override
  void initState() {
    super.initState();
    _loadAccuracyData();
  }

  Future<void> _loadAccuracyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _predictionService.getPredictionAccuracy();
      setState(() {
        _accuracyData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 错误处理
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预测准确率分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAccuracyData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAccuracyOverview(),
                  const SizedBox(height: 24),
                  _buildWinPredictionChart(),
                  const SizedBox(height: 24),
                  _buildTotalScorePredictionChart(),
                  const SizedBox(height: 24),
                  _buildSpreadPredictionChart(),
                  const SizedBox(height: 24),
                  _buildAccuracyTrend(),
                ],
              ),
            ),
    );
  }

  Widget _buildAccuracyOverview() {
    final winAccuracy = _accuracyData['win_prediction']?['accuracy'] ?? 0.0;
    final totalScoreRmse = _accuracyData['total_score_prediction']?['rmse'] ?? 0.0;
    final spreadAccuracy = _accuracyData['spread_prediction']?['accuracy'] ?? 0.0;

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
              '预测准确率概览',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '胜负预测',
                    '${(winAccuracy * 100).toStringAsFixed(1)}%',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    '总分预测RMSE',
                    totalScoreRmse.toStringAsFixed(2),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricCard(
                    '让分盘预测',
                    '${(spreadAccuracy * 100).toStringAsFixed(1)}%',
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinPredictionChart() {
    final correct = _accuracyData['win_prediction']?['correct'] ?? 0;
    final total = _accuracyData['win_prediction']?['total'] ?? 1;
    final incorrect = total - correct;

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
              '胜负预测准确率',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: correct.toDouble(),
                      title: '正确',
                      color: Colors.green,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: incorrect.toDouble(),
                      title: '错误',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('正确', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('错误', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalScorePredictionChart() {
    // 这里使用模拟数据，实际应用中应该从_accuracyData中获取
    final List<double> errors = List.generate(20, (index) => (index - 10) * 2.0);
    final List<int> frequencies = List.generate(20, (index) {
      if (index < 5) return index + 1;
      if (index < 10) return 10 - index;
      if (index < 15) return index - 9;
      return 20 - index;
    });

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
              '总分预测误差分布',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  maxY: frequencies.reduce((a, b) => a > b ? a : b).toDouble(),
                  barGroups: List.generate(
                    errors.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: frequencies[index].toDouble(),
                          color: errors[index].abs() <= 5
                              ? Colors.green
                              : Colors.orange,
                          width: 8,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 5 != 0) return const SizedBox();
                          return Text(
                            errors[value.toInt()].toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                '预测误差 (预测值 - 实际值)',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpreadPredictionChart() {
    final correct = _accuracyData['spread_prediction']?['correct'] ?? 0;
    final total = _accuracyData['spread_prediction']?['total'] ?? 1;
    final incorrect = total - correct;

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
              '让分盘预测准确率',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: correct.toDouble(),
                      title: '正确',
                      color: Colors.blue,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: incorrect.toDouble(),
                      title: '错误',
                      color: Colors.red,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('正确', Colors.blue),
                const SizedBox(width: 24),
                _buildLegendItem('错误', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccuracyTrend() {
    // 这里使用模拟数据，实际应用中应该从_accuracyData中获取
    final List<double> winAccuracyTrend = List.generate(
      10,
      (index) => 0.6 + (index / 50),
    );
    final List<double> totalRmseTrend = List.generate(
      10,
      (index) => 7.0 - (index / 20),
    );
    final List<double> spreadAccuracyTrend = List.generate(
      10,
      (index) => 0.55 + (index / 40),
    );

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
              '预测准确率趋势',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        winAccuracyTrend.length,
                        (index) => FlSpot(index.toDouble(), winAccuracyTrend[index]),
                      ),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: List.generate(
                        spreadAccuracyTrend.length,
                        (index) => FlSpot(index.toDouble(), spreadAccuracyTrend[index]),
                      ),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value * 100).toInt()}%',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() % 2 != 0) return const SizedBox();
                          return Text(
                            '${value.toInt() + 1}月',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  minX: 0,
                  maxX: winAccuracyTrend.length - 1.0,
                  minY: 0.5,
                  maxY: 0.9,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('胜负预测', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('让分盘预测', Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
