import 'package:flutter/material.dart';
import 'package:nba_prediction_app/models/team.dart';
import 'package:nba_prediction_app/services/prediction_service.dart';
import 'package:nba_prediction_app/widgets/prediction_result_card.dart';
import 'package:nba_prediction_app/widgets/team_selector.dart';
import 'package:intl/intl.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final PredictionService _predictionService = PredictionService();
  List<Team> _teams = [];
  Team? _homeTeam;
  Team? _awayTeam;
  DateTime _gameDate = DateTime.now();
  bool _isLoading = true;
  bool _isPredicting = false;
  Map<String, dynamic>? _predictionResult;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final teams = await _predictionService.getAllTeams();
      setState(() {
        _teams = teams;
        if (teams.length >= 2) {
          _homeTeam = teams[0];
          _awayTeam = teams[1];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // 错误处理
    }
  }

  Future<void> _generatePrediction() async {
    if (_homeTeam == null || _awayTeam == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择主队和客队')),
      );
      return;
    }

    setState(() {
      _isPredicting = true;
    });

    try {
      final prediction = await _predictionService.generatePrediction(
        _homeTeam!.id,
        _awayTeam!.id,
        _gameDate,
      );
      
      setState(() {
        _predictionResult = prediction;
        _isPredicting = false;
      });
    } catch (e) {
      setState(() {
        _isPredicting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('生成预测失败: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('比赛预测'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTeamSelection(),
                  const SizedBox(height: 24),
                  _buildDateSelection(),
                  const SizedBox(height: 24),
                  _buildPredictButton(),
                  const SizedBox(height: 24),
                  if (_isPredicting)
                    const Center(child: CircularProgressIndicator())
                  else if (_predictionResult != null)
                    PredictionResultCard(
                      homeTeam: _homeTeam!,
                      awayTeam: _awayTeam!,
                      gameDate: _gameDate,
                      prediction: _predictionResult!,
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildTeamSelection() {
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
              '选择球队',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TeamSelector(
                    label: '主队',
                    teams: _teams,
                    selectedTeam: _homeTeam,
                    onChanged: (team) {
                      setState(() {
                        _homeTeam = team;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TeamSelector(
                    label: '客队',
                    teams: _teams,
                    selectedTeam: _awayTeam,
                    onChanged: (team) {
                      setState(() {
                        _awayTeam = team;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelection() {
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
              '比赛日期',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _gameDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    _gameDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_gameDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _generatePrediction,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          '生成预测',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
