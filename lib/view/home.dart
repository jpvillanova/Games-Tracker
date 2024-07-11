import 'package:flutter/material.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/view/review.dart';
import '../controller/game_controller.dart';
import '../model/game.dart';
import '../helper/auth.dart';
import '../model/user.dart';

class Home extends StatefulWidget {
  final User? user;

  const Home({super.key, this.user});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  final GameController _gameController = GameController();
  final GenreController _genreController =
      GenreController(); // Define _genreController here
  List<Game> _games = [];
  String? _releaseDate;
  int? _genreId;
  double? _minScore;

  String _gameName = '';
  String _gameReleaseDate = '';
  String _gameDescription = '';

  @override
  void initState() {
    super.initState();
    _fetchGames(); // Carrega os jogos quando o widget é inicializado
  }

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
          if (widget.user != null)
            ElevatedButton(
              onPressed: _createGame,
              child: const Text('Create Game'),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _games.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(_games[index].name),
                    subtitle: Text(
                        "Average Score: ${_games[index].averageScore.toStringAsFixed(1)}"),
                    trailing: widget.user != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _editGame(_games[index]);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  _deleteGame(_games[index]);
                                },
                              ),
                            ],
                          )
                        : null,
                    onTap: () async {
                      // Mark this function as async
                      var result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDetailsScreen(
                              game: _games[index], user: widget.user),
                        ),
                      );
                      if (result == true) {
                        _fetchGames();
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _createGame() async {
    TextEditingController textController =
        TextEditingController(); // Controlador para o gênero
    GenreController genreController = GenreController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Game'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Game Name',
                  ),
                  onChanged: (value) => _gameName = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Release Date (YYYY-MM-DD)',
                  ),
                  onChanged: (value) => _gameReleaseDate = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                  onChanged: (value) => _gameDescription = value,
                ),
                TextFormField(
                  controller:
                      textController, // Controlador para capturar o nome do gênero
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () async {
                // Passa o texto do controlador para o método getOrCreateGenreId
                int genreId = await genreController
                    .getOrCreateGenreId(textController.text);
                print(
                    "Genre ID: $genreId"); // Adiciona a impressão do genreId aqui
                await _saveGameToDatabase(
                    genreId); // Modifica esta função para aceitar genreId
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveGameToDatabase(int genreId) async {
    Game newGame = Game(
      userId: widget.user?.id ?? 0,
      name: _gameName,
      releaseDate: _gameReleaseDate,
      description: _gameDescription,
      averageScore: 0.0,
    );
    int gameId = await _gameController.createGame(newGame);
    await _genreController.createOrUpdateGameGenreAssociation(gameId, genreId);
    _fetchGames();
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

    // Adicionando impressão de debug para cada jogo
    for (var game in _games) {
      print('Game: ${game.name}, Average Score: ${game.averageScore}');
    }
  }

  void _editGame(Game game) async {
    TextEditingController nameController =
        TextEditingController(text: game.name);
    TextEditingController releaseDateController =
        TextEditingController(text: game.releaseDate);
    TextEditingController descriptionController =
        TextEditingController(text: game.description);
    TextEditingController genreController =
        TextEditingController(); // Controlador para o gênero
    GenreController genreCtrl = GenreController();

    // Carrega o nome do gênero do banco de dados
    String? genreName = await genreCtrl.getGenreNameByGameId(game.id!);
    genreController.text =
        genreName ?? ""; // Define o nome do gênero no controlador

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Game'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Game Name'),
                ),
                TextFormField(
                  controller: releaseDateController,
                  decoration: const InputDecoration(
                      labelText: 'Release Date (YYYY-MM-DD)'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: genreController,
                  decoration: const InputDecoration(labelText: 'Genre'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save Changes'),
              onPressed: () async {
                int genreId =
                    await genreCtrl.getOrCreateGenreId(genreController.text);
                game.name = nameController.text;
                game.releaseDate = releaseDateController.text;
                game.description = descriptionController.text;
                await _gameController.editGame(game);
                await _genreController.createOrUpdateGameGenreAssociation(
                    game.id!, genreId);
                _fetchGames();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteGame(Game game) async {
    await _gameController.deleteGame(game);
    _fetchGames();
  }
}
