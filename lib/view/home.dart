import 'package:flutter/material.dart';
import '../controller/game_controller.dart';
import '../model/game.dart';
import '../helper/auth.dart';
import '../model/user.dart';

class Home extends StatefulWidget {
  final User? user;

  const Home(
      {super.key,
      this.user}); // Remove 'required' and add default value of null

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final GameController _gameController = GameController();
  List<Game> _games = [];
  String? _releaseDate;
  int? _genreId;
  double? _minScore;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.user != null ? "Welcome, ${widget.user!.name}" : "Welcome"),
        actions: <Widget>[
          IconButton(
            onPressed: () => Auth.signOut().then((_) {
              Navigator.of(context).pushReplacementNamed('/login');
            }),
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Release Date',
                hintText: 'YYYY-MM-DD',
              ),
              onChanged: (value) => _releaseDate = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Genre ID',
              ),
              onChanged: (value) => _genreId = int.tryParse(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Minimum Score',
              ),
              onChanged: (value) => _minScore = double.tryParse(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _games.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_games[index].name),
                  subtitle: Text(
                      "Average Score: ${_games[index].averageScore.toStringAsFixed(1)}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _fetchGames() async {
    var games = await _gameController.getFilteredGames(
      releaseDate: _releaseDate,
      genreId: _genreId,
      minScore: _minScore,
    );
    setState(() {
      _games = games;
    });
  }
}
