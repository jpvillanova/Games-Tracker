import 'package:flutter/material.dart';
import 'package:login_app/controller/genre_controller.dart';
import 'package:login_app/model/genre.dart';
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
  double? _averageScore; // Replace _minScore with _averageScore

  String _gameName = '';
  String _gameReleaseDate = '';
  String _gameDescription = '';

  List<Genre> _genres = []; // Lista para armazenar os gêneros
  Genre? _selectedGenre; // Gênero selecionado

  @override
  void initState() {
    super.initState();
    _fetchGames();
    _fetchGenres(); // Carrega os gêneros quando o widget é inicializado
  }

  void _fetchGenres() async {
    var genres =
        await _genreController.getGenres(); // Supõe que existe esse método
    setState(() {
      _genres = genres;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Game> userGames =
        _games.where((game) => game.userId == widget.user?.id).toList();

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
          // Aqui você pode exibir os cards apenas dos jogos do usuário
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
                labelText: 'Average Score',
              ),
              onChanged: (value) => _averageScore = double.tryParse(
                  value), // Replace _minScore with _averageScore
            ),
          ),
          if (widget.user != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createGame,
                  child: const Text('Create Game'),
                ),
                ElevatedButton(
                  onPressed: _createGenre, // Add this button for creating genre
                  child: const Text('Create Genre'),
                ),
                ElevatedButton(
                  onPressed: _searchGames,
                  child: const Text('Search'),
                ),
              ],
            ),
          if (widget.user == null) // Show search button only if user is null
            ElevatedButton(
              onPressed: _searchGames,
              child: const Text('Search'),
            ),
          if (_releaseDate == null &&
              _genreId == null &&
              _averageScore == null) // Replace _minScore with _averageScore
            for (var game in userGames) // Change _games to userGames
              Card(
                child: ListTile(
                  title: Text(game.name),
                  subtitle: Text(
                      "Average Score: ${game.averageScore.toStringAsFixed(1)}"),
                  trailing: widget.user != null &&
                          game.userId ==
                              widget.user
                                  ?.id // Check if the game belongs to the user
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editGame(game);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteGame(game);
                              },
                            ),
                          ],
                        )
                      : null,
                  onTap: () async {
                    var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameDetailsScreen(game: game, user: widget.user),
                      ),
                    );
                    if (result == true) {
                      _fetchGames();
                    }
                  },
                ),
              ),
          if (_releaseDate != null ||
              _genreId != null ||
              _averageScore != null) // Replace _minScore with _averageScore
            Expanded(
              child: ListView.builder(
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_games[index].name),
                      subtitle: Text(
                          "Average Score: ${_games[index].averageScore.toStringAsFixed(1)}"),
                      trailing: widget.user != null &&
                              _games[index].userId == widget.user?.id
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
                DropdownButtonFormField<Genre>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(
                    labelText: 'Genre',
                  ),
                  onChanged: (Genre? newValue) {
                    setState(() {
                      _selectedGenre = newValue;
                    });
                  },
                  items: _genres.map<DropdownMenuItem<Genre>>((Genre genre) {
                    return DropdownMenuItem<Genre>(
                      value: genre,
                      child: Text(genre.name),
                    );
                  }).toList(),
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
                if (_selectedGenre != null) {
                  await _saveGameToDatabase(_selectedGenre!.id!);
                  Navigator.of(context).pop();
                }
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
      averageScore: _averageScore, // Replace _minScore with _averageScore
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
                DropdownButtonFormField<Genre>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(labelText: 'Genre'),
                  onChanged: (Genre? newValue) {
                    setState(() {
                      _selectedGenre = newValue;
                    });
                  },
                  items: _genres.map<DropdownMenuItem<Genre>>((Genre genre) {
                    return DropdownMenuItem<Genre>(
                      value: genre,
                      child: Text(genre.name),
                    );
                  }).toList(),
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

  void _createGenre() async {
    TextEditingController genreNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create New Genre'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: genreNameController,
                  decoration: const InputDecoration(
                    labelText: 'Genre Name',
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
                Genre newGenre = Genre(name: genreNameController.text);
                await _genreController.createGenre(newGenre);
                _fetchGenres(); // Fetch genres after creating a new one
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchGames() {
    _fetchGames(); // Fetch games based on filters
  }
}
