import 'package:flutter/material.dart';
import 'package:nba_prediction_app/widgets/upcoming_game_card.dart';
import 'package:nba_prediction_app/widgets/performance_metrics.dart';
import 'package:nba_prediction_app/services/prediction_service.dart';
import 'package:nba_prediction_app/models/game.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PredictionService _predictionService = PredictionService();
  List<Game> _upcomingGames = [];
  bool _isLoading = true;
  Map<String, double> _performanceMetrics = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final upcomingGames = await _predictionService.getUpcomingGames();
      final metrics = await _predictionService.getPerformanceMetrics();
      
      setState(() {
        _upcomingGames = upcomingGames;
        _performanceMetrics = metrics;
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
        title: const Text('NBA预测系统'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSystemOverview(),
                      const SizedBox(height: 24),
                      _buildUpcomingGames(),
                      const SizedBox(height: 24),
                      PerformanceMetrics(metrics: _performanceMetrics),
                    ],
                  ),
                ),
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
          children: [
            const Text(
              '系统概述',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'NBA比赛预测系统是一个基于多维度数据分析和机器学习建模的预测平台，旨在提供高准确率的NBA比赛胜负、总分和让分盘预测。',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              '系统融合了五个核心预测层面：',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4),
            _buildPredictionLayer('基础统计学预测', 35),
            _buildPredictionLayer('动态系统建模', 25),
            _buildPredictionLayer('机器学习特征工程', 30),
            _buildPredictionLayer('市场信号整合', 8),
            _buildPredictionLayer('不确定性量化', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionLayer(String name, int weight) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$name ($weight%)',
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingGames() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '即将进行的比赛',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _upcomingGames.isEmpty
            ? const Center(
                child: Text(
                  '暂无即将进行的比赛',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _upcomingGames.length,
                itemBuilder: (context, index) {
                  return UpcomingGameCard(game: _upcomingGames[index]);
                },
              ),
      ],
    );
  }
}
