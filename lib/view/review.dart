import 'package:flutter/material.dart';
import 'package:login_app/model/user.dart';
import '../model/game.dart';
import '../model/review.dart';
import '../controller/review_controller.dart';
import 'package:intl/intl.dart'; // Adicione esta importação para formatar datas

class GameDetailsScreen extends StatefulWidget {
  final Game game;
  final User? user; // Adicione este parâmetro para passar o usuário logado
  final VoidCallback onReviewAdded; // Adicione este parâmetro para o callback

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
  final ReviewController _reviewController =
      ReviewController(); // Add this line

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
        print("Failed to fetch reviews: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch reviews from database')),
        );
      }
    } else {
      print("Game ID is null");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game ID is null')),
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
          title: Text('Add Review'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
                TextFormField(
                  controller: _scoreController,
                  decoration: InputDecoration(labelText: 'Score (0-10)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
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
                      widget.onReviewAdded(); // Chama o callback
                      Navigator.of(context).pop(); // Fecha a tela
                      _fetchReviews(); // Recarrega os reviews após adicionar um novo
                      print('alouas');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add review')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('User ID or Game ID is null')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Please enter a valid score between 0 and 10')),
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
                Text("Release Date: ${widget.game.releaseDate}",
                    style: TextStyle(fontSize: 16)),
                Text("Description: ${widget.game.description}",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          // Mostra todos os reviews
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
                          Text("Score: ${reviews[index].score}"),
                          Text("Date: ${reviews[index].date}"),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          // Botão 'Add Review' em uma nova linha
          if (widget.user != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: _addReview,
                  child: Text('Add Review'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
