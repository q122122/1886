import 'package:flutter/material.dart';
import 'package:nba_prediction_app/models/game.dart';
import 'package:nba_prediction_app/services/prediction_service.dart';
import 'package:nba_prediction_app/widgets/game_history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final PredictionService _predictionService = PredictionService();
  List<Game> _historicalGames = [];
  bool _isLoading = true;
  Game? _selectedGame;

  @override
  void initState() {
    super.initState();
    _loadHistoricalGames();
  }

  Future<void> _loadHistoricalGames() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final games = await _predictionService.getHistoricalGames();
      setState(() {
        _historicalGames = games;
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
        title: const Text('历史数据分析'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistoricalGames,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historicalGames.isEmpty
              ? const Center(child: Text('暂无历史比赛数据'))
              : Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildGamesList(),
                    ),
                    if (_selectedGame != null)
                      Expanded(
                        flex: 2,
                        child: _buildGameDetails(),
                      ),
                  ],
                ),
    );
  }

  Widget _buildGamesList() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        itemCount: _historicalGames.length,
        itemBuilder: (context, index) {
          final game = _historicalGames[index];
          return ListTile(
            title: Text('${game.homeTeam.name} vs ${game.awayTeam.name}'),
            subtitle: Text(game.date),
            trailing: Text(
              '${game.homeScore} - ${game.awayScore}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            selected: _selectedGame?.id == game.id,
            selectedTileColor: Colors.blue.withOpacity(0.2),
            onTap: () {
              setState(() {
                _selectedGame = game;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildGameDetails() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _selectedGame != null
            ? GameHistoryCard(game: _selectedGame!)
            : const Center(child: Text('请选择一场比赛查看详情')),
      ),
    );
  }
}
