import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nba_prediction_app/models/team.dart';
import 'package:nba_prediction_app/models/game.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PredictionService {
  static final PredictionService _instance = PredictionService._internal();
  static PredictionService get instance => _instance;

  PredictionService._internal();
  factory PredictionService() => _instance;

  // API基础URL，实际应用中应替换为真实的API地址
  final String _baseUrl = 'https://api.nbaprediction.com/v1';
  
  // API密钥，实际应用中应从安全存储中获取
  final String _apiKey = 'your_api_key';

  // 本地数据库实例
  Database? _database;

  // 初始化数据库
  Future<void> initDatabase() async {
    if (_database != null) return;
    
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'nba_prediction.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 创建球队表
        await db.execute('''
        CREATE TABLE teams (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          abbr TEXT NOT NULL,
          conference TEXT NOT NULL,
          division TEXT NOT NULL
        )
        ''');
        
        // 创建比赛表
        await db.execute('''
        CREATE TABLE games (
          id INTEGER PRIMARY KEY,
          date TEXT NOT NULL,
          home_team_id INTEGER NOT NULL,
          away_team_id INTEGER NOT NULL,
          home_score INTEGER,
          away_score INTEGER,
          status TEXT NOT NULL,
          FOREIGN KEY (home_team_id) REFERENCES teams (id),
          FOREIGN KEY (away_team_id) REFERENCES teams (id)
        )
        ''');
        
        // 创建预测表
        await db.execute('''
        CREATE TABLE predictions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          game_id INTEGER NOT NULL,
          win_probability REAL NOT NULL,
          total_score REAL NOT NULL,
          spread REAL NOT NULL,
          timestamp TEXT NOT NULL,
          FOREIGN KEY (game_id) REFERENCES games (id)
        )
        ''');
        
        // 初始化球队数据
        await _initTeamsData(db);
        
        // 初始化比赛数据
        await _initGamesData(db);
      },
    );
  }

  // 初始化球队数据
  Future<void> _initTeamsData(Database db) async {
    final teams = [
      {'id': 1, 'name': 'Atlanta Hawks', 'abbr': 'ATL', 'conference': 'East', 'division': 'Southeast'},
      {'id': 2, 'name': 'Boston Celtics', 'abbr': 'BOS', 'conference': 'East', 'division': 'Atlantic'},
      {'id': 3, 'name': 'Brooklyn Nets', 'abbr': 'BKN', 'conference': 'East', 'division': 'Atlantic'},
      {'id': 4, 'name': 'Charlotte Hornets', 'abbr': 'CHA', 'conference': 'East', 'division': 'Southeast'},
      {'id': 5, 'name': 'Chicago Bulls', 'abbr': 'CHI', 'conference': 'East', 'division': 'Central'},
      {'id': 6, 'name': 'Cleveland Cavaliers', 'abbr': 'CLE', 'conference': 'East', 'division': 'Central'},
      {'id': 7, 'name': 'Dallas Mavericks', 'abbr': 'DAL', 'conference': 'West', 'division': 'Southwest'},
      {'id': 8, 'name': 'Denver Nuggets', 'abbr': 'DEN', 'conference': 'West', 'division': 'Northwest'},
      {'id': 9, 'name': 'Detroit Pistons', 'abbr': 'DET', 'conference': 'East', 'division': 'Central'},
      {'id': 10, 'name': 'Golden State Warriors', 'abbr': 'GSW', 'conference': 'West', 'division': 'Pacific'},
      {'id': 11, 'name': 'Houston Rockets', 'abbr': 'HOU', 'conference': 'West', 'division': 'Southwest'},
      {'id': 12, 'name': 'Indiana Pacers', 'abbr': 'IND', 'conference': 'East', 'division': 'Central'},
      {'id': 13, 'name': 'Los Angeles Clippers', 'abbr': 'LAC', 'conference': 'West', 'division': 'Pacific'},
      {'id': 14, 'name': 'Los Angeles Lakers', 'abbr': 'LAL', 'conference': 'West', 'division': 'Pacific'},
      {'id': 15, 'name': 'Memphis Grizzlies', 'abbr': 'MEM', 'conference': 'West', 'division': 'Southwest'},
      {'id': 16, 'name': 'Miami Heat', 'abbr': 'MIA', 'conference': 'East', 'division': 'Southeast'},
      {'id': 17, 'name': 'Milwaukee Bucks', 'abbr': 'MIL', 'conference': 'East', 'division': 'Central'},
      {'id': 18, 'name': 'Minnesota Timberwolves', 'abbr': 'MIN', 'conference': 'West', 'division': 'Northwest'},
      {'id': 19, 'name': 'New Orleans Pelicans', 'abbr': 'NOP', 'conference': 'West', 'division': 'Southwest'},
      {'id': 20, 'name': 'New York Knicks', 'abbr': 'NYK', 'conference': 'East', 'division': 'Atlantic'},
      {'id': 21, 'name': 'Oklahoma City Thunder', 'abbr': 'OKC', 'conference': 'West', 'division': 'Northwest'},
      {'id': 22, 'name': 'Orlando Magic', 'abbr': 'ORL', 'conference': 'East', 'division': 'Southeast'},
      {'id': 23, 'name': 'Philadelphia 76ers', 'abbr': 'PHI', 'conference': 'East', 'division': 'Atlantic'},
      {'id': 24, 'name': 'Phoenix Suns', 'abbr': 'PHX', 'conference': 'West', 'division': 'Pacific'},
      {'id': 25, 'name': 'Portland Trail Blazers', 'abbr': 'POR', 'conference': 'West', 'division': 'Northwest'},
      {'id': 26, 'name': 'Sacramento Kings', 'abbr': 'SAC', 'conference': 'West', 'division': 'Pacific'},
      {'id': 27, 'name': 'San Antonio Spurs', 'abbr': 'SAS', 'conference': 'West', 'division': 'Southwest'},
      {'id': 28, 'name': 'Toronto Raptors', 'abbr': 'TOR', 'conference': 'East', 'division': 'Atlantic'},
      {'id': 29, 'name': 'Utah Jazz', 'abbr': 'UTA', 'conference': 'West', 'division': 'Northwest'},
      {'id': 30, 'name': 'Washington Wizards', 'abbr': 'WAS', 'conference': 'East', 'division': 'Southeast'},
    ];
    
    for (final team in teams) {
      await db.insert('teams', team);
    }
  }

  // 初始化比赛数据（模拟数据）
  Future<void> _initGamesData(Database db) async {
    final now = DateTime.now();
    
    // 生成过去30天的比赛数据
    for (int i = 30; i > 0; i--) {
      final gameDate = now.subtract(Duration(days: i));
      final gameDateStr = '${gameDate.year}-${gameDate.month.toString().padLeft(2, '0')}-${gameDate.day.toString().padLeft(2, '0')}';
      
      // 每天4-6场比赛
      final numGames = 4 + (i % 3);
      final usedTeams = <int>[];
      
      for (int j = 0; j < numGames; j++) {
        int homeTeamId, awayTeamId;
        
        do {
          homeTeamId = 1 + (i * j) % 30;
        } while (usedTeams.contains(homeTeamId));
        usedTeams.add(homeTeamId);
        
        do {
          awayTeamId = 1 + ((i * j + 15) % 30);
        } while (usedTeams.contains(awayTeamId) || awayTeamId == homeTeamId);
        usedTeams.add(awayTeamId);
        
        final homeScore = 90 + (i * j) % 40;
        final awayScore = 90 + ((i * j + 10) % 40);
        
        final gameId = int.parse('${gameDate.year}${gameDate.month.toString().padLeft(2, '0')}${gameDate.day.toString().padLeft(2, '0')}${j+1}');
        
        await db.insert('games', {
          'id': gameId,
          'date': gameDateStr,
          'home_team_id': homeTeamId,
          'away_team_id': awayTeamId,
          'home_score': homeScore,
          'away_score': awayScore,
          'status': 'Final',
        });
        
        // 生成预测数据
        final winProb = 0.4 + (i * j % 40) / 100;
        final totalScore = 200 + (i * j % 30);
        final spread = -10 + (i * j % 20);
        final timestamp = '$gameDateStr 09:00:00';
        
        await db.insert('predictions', {
          'game_id': gameId,
          'win_probability': winProb,
          'total_score': totalScore,
          'spread': spread,
          'timestamp': timestamp,
        });
      }
    }
    
    // 生成未来7天的比赛数据
    for (int i = 1; i <= 7; i++) {
      final gameDate = now.add(Duration(days: i));
      final gameDateStr = '${gameDate.year}-${gameDate.month.toString().padLeft(2, '0')}-${gameDate.day.toString().padLeft(2, '0')}';
      
      // 每天4-6场比赛
      final numGames = 4 + (i % 3);
      final usedTeams = <int>[];
      
      for (int j = 0; j < numGames; j++) {
        int homeTeamId, awayTeamId;
        
        do {
          homeTeamId = 1 + (i * j) % 30;
        } while (usedTeams.contains(homeTeamId));
        usedTeams.add(homeTeamId);
        
        do {
          awayTeamId = 1 + ((i * j + 15) % 30);
        } while (usedTeams.contains(awayTeamId) || awayTeamId == homeTeamId);
        usedTeams.add(awayTeamId);
        
        final gameId = int.parse('${gameDate.year}${gameDate.month.toString().padLeft(2, '0')}${gameDate.day.toString().padLeft(2, '0')}${j+1}');
        
        await db.insert('games', {
          'id': gameId,
          'date': gameDateStr,
          'home_team_id': homeTeamId,
          'away_team_id': awayTeamId,
          'home_score': null,
          'away_score': null,
          'status': 'Scheduled',
        });
        
        // 生成预测数据
        final winProb = 0.4 + (i * j % 40) / 100;
        final totalScore = 200 + (i * j % 30);
        final spread = -10 + (i * j % 20);
        final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} 09:00:00';
        
        await db.insert('predictions', {
          'game_id': gameId,
          'win_probability': winProb,
          'total_score': totalScore,
          'spread': spread,
          'timestamp': timestamp,
        });
      }
    }
  }

  // 获取所有球队
  Future<List<Team>> getAllTeams() async {
    await initDatabase();
    
    try {
      // 尝试从API获取数据
      final response = await http.get(
        Uri.parse('$_baseUrl/teams'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final List<dynamic> teamsJson = json.decode(response.body);
        return teamsJson.map((json) => Team.fromJson(json)).toList();
      }
    } catch (e) {
      // API请求失败，使用本地数据
      print('API请求失败，使用本地数据: $e');
    }
    
    // 从本地数据库获取数据
    final List<Map<String, dynamic>> maps = await _database!.query('teams');
    return List.generate(maps.length, (i) {
      return Team(
        id: maps[i]['id'],
        name: maps[i]['name'],
        abbr: maps[i]['abbr'],
        conference: maps[i]['conference'],
        division: maps[i]['division'],
      );
    });
  }

  // 获取即将进行的比赛
  Future<List<Game>> getUpcomingGames() async {
    await initDatabase();
    
    try {
      // 尝试从API获取数据
      final response = await http.get(
        Uri.parse('$_baseUrl/games/upcoming'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final List<dynamic> gamesJson = json.decode(response.body);
        return gamesJson.map((json) => Game.fromJson(json)).toList();
      }
    } catch (e) {
      // API请求失败，使用本地数据
      print('API请求失败，使用本地数据: $e');
    }
    
    // 从本地数据库获取数据
    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
      SELECT g.*, 
             ht.id as home_team_id, ht.name as home_team_name, ht.abbr as home_team_abbr,
             at.id as away_team_id, at.name as away_team_name, at.abbr as away_team_abbr,
             p.win_probability, p.total_score, p.spread
      FROM games g
      JOIN teams ht ON g.home_team_id = ht.id
      JOIN teams at ON g.away_team_id = at.id
      LEFT JOIN predictions p ON g.id = p.game_id
      WHERE g.status = 'Scheduled'
      ORDER BY g.date
      LIMIT 5
    ''');
    
    return List.generate(maps.length, (i) {
      return Game(
        id: maps[i]['id'],
        date: maps[i]['date'],
        homeTeam: Team(
          id: maps[i]['home_team_id'],
          name: maps[i]['home_team_name'],
          abbr: maps[i]['home_team_abbr'],
          conference: '',
          division: '',
        ),
        awayTeam: Team(
          id: maps[i]['away_team_id'],
          name: maps[i]['away_team_name'],
          abbr: maps[i]['away_team_abbr'],
          conference: '',
          division: '',
        ),
        homeScore: maps[i]['home_score'],
        awayScore: maps[i]['away_score'],
        status: maps[i]['status'],
        prediction: {
          'win_probability': maps[i]['win_probability'],
          'total_score': maps[i]['total_score'],
          'spread': maps[i]['spread'],
        },
      );
    });
  }

  // 获取历史比赛
  Future<List<Game>> getHistoricalGames() async {
    await initDatabase();
    
    try {
      // 尝试从API获取数据
      final response = await http.get(
        Uri.parse('$_baseUrl/games/historical'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final List<dynamic> gamesJson = json.decode(response.body);
        return gamesJson.map((json) => Game.fromJson(json)).toList();
      }
    } catch (e) {
      // API请求失败，使用本地数据
      print('API请求失败，使用本地数据: $e');
    }
    
    // 从本地数据库获取数据
    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
      SELECT g.*, 
             ht.id as home_team_id, ht.name as home_team_name, ht.abbr as home_team_abbr,
             at.id as away_team_id, at.name as away_team_name, at.abbr as away_team_abbr,
             p.win_probability, p.total_score, p.spread
      FROM games g
      JOIN teams ht ON g.home_team_id = ht.id
      JOIN teams at ON g.away_team_id = at.id
      LEFT JOIN predictions p ON g.id = p.game_id
      WHERE g.status = 'Final'
      ORDER BY g.date DESC
      LIMIT 20
    ''');
    
    return List.generate(maps.length, (i) {
      return Game(
        id: maps[i]['id'],
        date: maps[i]['date'],
        homeTeam: Team(
          id: maps[i]['home_team_id'],
          name: maps[i]['home_team_name'],
          abbr: maps[i]['home_team_abbr'],
          conference: '',
          division: '',
        ),
        awayTeam: Team(
          id: maps[i]['away_team_id'],
          name: maps[i]['away_team_name'],
          abbr: maps[i]['away_team_abbr'],
          conference: '',
          division: '',
        ),
        homeScore: maps[i]['home_score'],
        awayScore: maps[i]['away_score'],
        status: maps[i]['status'],
        prediction: {
          'win_probability': maps[i]['win_probability'],
          'total_score': maps[i]['total_score'],
          'spread': maps[i]['spread'],
        },
      );
    });
  }

  // 获取预测准确率
  Future<Map<String, dynamic>> getPredictionAccuracy() async {
    await initDatabase();
    
    try {
      // 尝试从API获取数据
      final response = await http.get(
        Uri.parse('$_baseUrl/predictions/accuracy'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // API请求失败，使用本地数据
      print('API请求失败，使用本地数据: $e');
    }
    
    // 从本地数据库计算准确率
    
    // 胜负预测准确率
    final winPredictionResult = await _database!.rawQuery('''
      SELECT COUNT(*) as total,
             SUM(CASE WHEN (p.win_probability > 0.5 AND g.home_score > g.away_score) OR 
                          (p.win_probability < 0.5 AND g.home_score < g.away_score) THEN 1 ELSE 0 END) as correct
      FROM predictions p
      JOIN games g ON p.game_id = g.id
      WHERE g.status = 'Final'
    ''');
    
    final winTotal = winPredictionResult.first['total'] as int;
    final winCorrect = winPredictionResult.first['correct'] as int;
    final winAccuracy = winTotal > 0 ? winCorrect / winTotal : 0.0;
    
    // 总分预测准确率
    final totalScoreResult = await _database!.rawQuery('''
      SELECT p.total_score, (g.home_score + g.away_score) as actual_total
      FROM predictions p
      JOIN games g ON p.game_id = g.id
      WHERE g.status = 'Final'
    ''');
    
    double rmse = 0.0;
    int within5Points = 0;
    
    if (totalScoreResult.isNotEmpty) {
      double sumSquaredError = 0.0;
      
      for (final row in totalScoreResult) {
        final predicted = row['total_score'] as double;
        final actual = (row['actual_total'] as int).toDouble();
        final error = predicted - actual;
        
        sumSquaredError += error * error;
        
        if ((predicted - actual).abs() <= 5) {
          within5Points++;
        }
      }
      
      rmse = (sumSquaredError / totalScoreResult.length).sqrt();
    }
    
    // 让分盘预测准确率
    final spreadPredictionResult = await _database!.rawQuery('''
      SELECT COUNT(*) as total,
             SUM(CASE WHEN (p.spread < 0 AND (g.home_score - g.away_score) > ABS(p.spread)) OR
                          (p.spread > 0 AND (g.away_score - g.home_score) > p.spread) THEN 1 ELSE 0 END) as correct
      FROM predictions p
      JOIN games g ON p.game_id = g.id
      WHERE g.status = 'Final'
    ''');
    
    final spreadTotal = spreadPredictionResult.first['total'] as int;
    final spreadCorrect = spreadPredictionResult.first['correct'] as int;
    final spreadAccuracy = spreadTotal > 0 ? spreadCorrect / spreadTotal : 0.0;
    
    return {
      'win_prediction': {
        'accuracy': winAccuracy,
        'correct': winCorrect,
        'total': winTotal,
      },
      'total_score_prediction': {
        'rmse': rmse,
        'within_5_points': totalScoreResult.isNotEmpty ? within5Points / totalScoreResult.length : 0.0,
      },
      'spread_prediction': {
        'accuracy': spreadAccuracy,
        'correct': spreadCorrect,
        'total': spreadTotal,
      },
    };
  }

  // 获取系统性能指标
  Future<Map<String, double>> getPerformanceMetrics() async {
    await initDatabase();
    
    try {
      // 尝试从API获取数据
      final response = await http.get(
        Uri.parse('$_baseUrl/system/performance'),
        headers: {'X-API-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'win_accuracy': data['win_accuracy'],
          'total_score_rmse': data['total_score_rmse'],
          'spread_accuracy': data['spread_accuracy'],
        };
      }
    } catch (e) {
      // API请求失败，使用本地数据
      print('API请求失败，使用本地数据: $e');
    }
    
    // 从本地数据库计算性能指标
    final accuracy = await getPredictionAccuracy();
    
    return {
      'win_accuracy': accuracy['win_prediction']['accuracy'],
      'total_score_rmse': accuracy['total_score_prediction']['rmse'],
      'spread_accuracy': accuracy['spread_prediction']['accuracy'],
    };
  }

  // 生成预测
  Future<Map<String, dynamic>> generatePrediction(int homeTeamId, int awayTeamId, DateTime gameDate) async {
    await initDatabase();
    
    final gameDateStr = '${gameDate.year}-${gameDate.month.toString().padLeft(2, '0')}-${gameDate.day.toString().padLeft(2, '0')}';
    
    try {
      // 尝试从API获取数据
      final response = await http.post(
        Uri.parse('$_baseUrl/predictions/generate'),
        headers: {
          'X-API-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'home_team_id': homeTeamId,
          'away_team_id': awayTeamId,
          'game_date': gameDateStr,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      // API请求失败，使用本地预测模型
      print('API请求失败，使用本地预测模型: $e');
    }
    
    // 使用本地数据生成预测
    // 这里使用简化的预测模型，实际系统会使用更复杂的模型
    
    // 获取球队历史数据
    final homeTeamGames = await _database!.rawQuery('''
      SELECT g.*, p.win_probability, p.total_score, p.spread
      FROM games g
      JOIN predictions p ON g.id = p.game_id
      WHERE (g.home_team_id = ? OR g.away_team_id = ?)
      AND g.status = 'Final'
      ORDER BY g.date DESC
      LIMIT 10
    ''', [homeTeamId, homeTeamId]);
    
    final awayTeamGames = await _database!.rawQuery('''
      SELECT g.*, p.win_probability, p.total_score, p.spread
      FROM games g
      JOIN predictions p ON g.id = p.game_id
      WHERE (g.home_team_id = ? OR g.away_team_id = ?)
      AND g.status = 'Final'
      ORDER BY g.date DESC
      LIMIT 10
    ''', [awayTeamId, awayTeamId]);
    
    // 如果没有足够的历史数据，使用随机预测
    if (homeTeamGames.isEmpty || awayTeamGames.isEmpty) {
      return {
        'win_probability': 0.5 + (DateTime.now().millisecond % 30) / 100,
        'total_score': 200 + (DateTime.now().millisecond % 30),
        'spread': -5 + (DateTime.now().millisecond % 10),
      };
    }
    
    // 计算基本统计数据
    double homeAvgPoints = 0;
    double homeAvgAllowed = 0;
    double homeWinRate = 0;
    
    for (final game in homeTeamGames) {
      if (game['home_team_id'] == homeTeamId) {
        homeAvgPoints += (game['home_score'] as int).toDouble();
        homeAvgAllowed += (game['away_score'] as int).toDouble();
        homeWinRate += (game['home_score'] as int) > (game['away_score'] as int) ? 1 : 0;
      } else {
        homeAvgPoints += (game['away_score'] as int).toDouble();
        homeAvgAllowed += (game['home_score'] as int).toDouble();
        homeWinRate += (game['away_score'] as int) > (game['home_score'] as int) ? 1 : 0;
      }
    }
    
    homeAvgPoints /= homeTeamGames.length;
    homeAvgAllowed /= homeTeamGames.length;
    homeWinRate /= homeTeamGames.length;
    
    double awayAvgPoints = 0;
    double awayAvgAllowed = 0;
    double awayWinRate = 0;
    
    for (final game in awayTeamGames) {
      if (game['home_team_id'] == awayTeamId) {
        awayAvgPoints += (game['home_score'] as int).toDouble();
        awayAvgAllowed += (game['away_score'] as int).toDouble();
        awayWinRate += (game['home_score'] as int) > (game['away_score'] as int) ? 1 : 0;
      } else {
        awayAvgPoints += (game['away_score'] as int).toDouble();
        awayAvgAllowed += (game['home_score'] as int).toDouble();
        awayWinRate += (game['away_score'] as int) > (game['home_score'] as int) ? 1 : 0;
      }
    }
    
    awayAvgPoints /= awayTeamGames.length;
    awayAvgAllowed /= awayTeamGames.length;
    awayWinRate /= awayTeamGames.length;
    
    // 主场优势因素
    const homeAdvantage = 3.5;
    
    // 预测胜率
    final homeExpectedPoints = (homeAvgPoints + awayAvgAllowed) / 2 + homeAdvantage;
    final awayExpectedPoints = (awayAvgPoints + homeAvgAllowed) / 2;
    
    double winProbability = 0.5 + (homeExpectedPoints - awayExpectedPoints) / 20;
    winProbability = winProbability.clamp(0.1, 0.9);
    
    // 预测总分
    final totalScore = homeExpectedPoints + awayExpectedPoints;
    
    // 预测让分
    final spread = awayExpectedPoints - homeExpectedPoints;
    
    return {
      'win_probability': winProbability,
      'total_score': totalScore,
      'spread': spread,
    };
  }
}
