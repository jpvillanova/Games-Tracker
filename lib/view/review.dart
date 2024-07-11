import 'package:flutter/material.dart';
import 'package:login_app/model/user.dart';
import '../model/game.dart';
import '../model/review.dart';
import '../controller/review_controller.dart';
import 'package:intl/intl.dart';

class GameDetailsScreen extends StatefulWidget {
  final Game game;
  final User? user;
  final VoidCallback onReviewAdded;

  const GameDetailsScreen(
      {Key? key,
      required this.game,
      required this.user,
      required this.onReviewAdded})
      : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  List<Review> reviews = [];
  final ReviewController _reviewController = ReviewController();

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() async {
    if (widget.game.id != null) {
      try {
        List<Review> fetchedReviews = await _reviewController
            .fetchRecentReviewsByGameId(widget.game.id!, 7);
        setState(() {
          reviews = fetchedReviews;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Falha ao buscar avaliações do banco de dados')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ID do jogo é nulo')),
      );
    }
  }

  void _addReview() {
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Adicionar Avaliação'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                TextFormField(
                  controller: _scoreController,
                  decoration: InputDecoration(labelText: 'Nota (0-10)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () async {
                final double? score = double.tryParse(_scoreController.text);
                if (score != null && score >= 0 && score <= 10) {
                  if (widget.user?.id != null && widget.game.id != null) {
                    Review newReview = Review(
                      userId: widget.user!.id!,
                      gameId: widget.game.id!,
                      score: score,
                      description: _descriptionController.text,
                      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                    );
                    int result = await _reviewController.addReview(newReview);
                    if (result != -1) {
                      widget.onReviewAdded();
                      Navigator.of(context).pop();
                      _fetchReviews();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Falha ao adicionar avaliação')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('ID do usuário ou do jogo é nulo')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Por favor, insira uma nota válida entre 0 e 10')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Data de Lançamento: ${widget.game.releaseDate}",
                    style: TextStyle(fontSize: 16)),
                Text("Descrição: ${widget.game.description}",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          if (reviews.length > 0)
            Expanded(
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(reviews[index].description),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nota: ${reviews[index].score}"),
                          Text("Data: ${reviews[index].date}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          if (widget.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _addReview,
                  child: Text('Adicionar Avaliação'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
