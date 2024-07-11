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
  final GenreController _genreController = GenreController();
  List<Game> _games = [];
  String? _filterReleaseDate;
  String? _filterGenreName;
  double? _filterAverageScore;

  String _gameName = '';
  String _gameReleaseDate = '';
  String _gameDescription = '';

  List<Genre> _genres = [];
  Genre? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _fetchGames();
    _fetchGenres();
  }

  void _fetchGenres() async {
    var genres = await _genreController.getGenres();
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
        title: Text(widget.user != null
            ? "Bem-vindo, ${widget.user!.name}"
            : "Bem-vindo"),
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
                labelText: 'Data de Lançamento',
                hintText: 'AAAA-MM-DD',
              ),
              onChanged: (value) =>
                  _filterReleaseDate = value.isEmpty ? null : value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome do Gênero',
              ),
              onChanged: (value) =>
                  _filterGenreName = value.isEmpty ? null : value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'Pontuação Média',
              ),
              onChanged: (value) =>
                  _filterAverageScore = double.tryParse(value),
            ),
          ),
          if (widget.user != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _createGame,
                  child: const Text('Criar Jogo'),
                ),
                ElevatedButton(
                  onPressed: _searchGames,
                  child: const Text('Buscar'),
                ),
                ElevatedButton(
                  onPressed: _createGenre,
                  child: const Text('Criar Gênero'),
                ),
              ],
            ),
          if (widget.user == null)
            ElevatedButton(
              onPressed: _searchGames,
              child: const Text('Buscar'),
            ),
          if (_filterReleaseDate == null &&
              _filterGenreName == null &&
              _filterAverageScore == null)
            for (var game in userGames)
              Card(
                child: ListTile(
                  title: Text(game.name),
                  subtitle: Text(
                      "Pontuação Média: ${game.averageScore.toStringAsFixed(1)}"),
                  trailing:
                      widget.user != null && game.userId == widget.user?.id
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
                        builder: (context) => GameDetailsScreen(
                            game: game,
                            user: widget.user,
                            onReviewAdded: () {
                              _fetchGames();
                            }),
                      ),
                    );
                    if (result == true) {
                      _fetchGames();
                    }
                  },
                ),
              ),
          if (_filterReleaseDate != null ||
              _filterGenreName != null ||
              _filterAverageScore != null)
            Expanded(
              child: ListView.builder(
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(_games[index].name),
                      subtitle: Text(
                          "Pontuação Média: ${_games[index].averageScore.toStringAsFixed(1)}"),
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
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameDetailsScreen(
                                game: _games[index],
                                user: widget.user,
                                onReviewAdded: () {
                                  _fetchGames();
                                }),
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
          title: const Text('Criar Novo Jogo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Nome do Jogo',
                  ),
                  onChanged: (value) => _gameName = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Data de Lançamento (AAAA-MM-DD)',
                  ),
                  onChanged: (value) => _gameReleaseDate = value,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                  ),
                  onChanged: (value) => _gameDescription = value,
                ),
                DropdownButtonFormField<Genre>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(
                    labelText: 'Gênero',
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
                  isExpanded: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Criar'),
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
    await _genreController.createGameGenreAssociation(gameId, genreId);
    _fetchGames();
  }

  void _fetchGames() async {
    int? genreId;
    if (_filterGenreName != null) {
      genreId = await _genreController.getGenreId(_filterGenreName!);
    } else {
      genreId = null;
    }

    var games = await _gameController.getFilteredGames(
      releaseDate: _filterReleaseDate,
      genreId: genreId,
      averageScore: _filterAverageScore,
    );

    setState(() {
      _games = games;
    });
  }

  void _editGame(Game game) async {
    TextEditingController nameController =
        TextEditingController(text: game.name);
    TextEditingController releaseDateController =
        TextEditingController(text: game.releaseDate);
    TextEditingController descriptionController =
        TextEditingController(text: game.description);
    GenreController genreCtrl = GenreController();

    String? genreName = await genreCtrl.getGenreNameByGameId(game.id!);
    _selectedGenre = _genres.firstWhere((genre) => genre.name == genreName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Jogo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome do Jogo'),
                ),
                TextFormField(
                  controller: releaseDateController,
                  decoration: const InputDecoration(
                      labelText: 'Data de Lançamento (AAAA-MM-DD)'),
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                ),
                DropdownButtonFormField<Genre>(
                  value: _selectedGenre,
                  decoration: const InputDecoration(labelText: 'Gênero'),
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
                  isExpanded: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Salvar Alterações'),
              onPressed: () async {
                int genreId =
                    await genreCtrl.getOrCreateGenreId(_selectedGenre!.name);
                game.name = nameController.text;
                game.releaseDate = releaseDateController.text;
                game.description = descriptionController.text;
                await _gameController.editGame(game);
                await _genreController.updateGameGenreAssociation(
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
          title: const Text('Criar Novo Gênero'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: genreNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Gênero',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Criar'),
              onPressed: () async {
                Genre newGenre = Genre(name: genreNameController.text);
                await _genreController.createGenre(newGenre);
                _fetchGenres();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _searchGames() {
    _fetchGames();
  }
}
