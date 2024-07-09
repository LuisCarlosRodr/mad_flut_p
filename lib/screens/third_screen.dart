import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({Key? key}) : super(key: key);

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _moodRating = 0;
  late DatabaseReference feedbackRef;

  @override
  void initState() {
    super.initState();
    feedbackRef = FirebaseDatabase.instance.reference().child('feedback');
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Third Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
            ),
            const SizedBox(height: 16.0),
            const Text('Mood Rating:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _moodRating = i;
                      });
                    },
                    child: Text(
                      _getMoodEmoji(i),
                      style: TextStyle(
                        fontSize: 24.0,
                        color: _moodRating == i ? Colors.amber : Colors.grey,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _submitFeedback(context, user),
              child: const Text('Submit Feedback'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder(
                stream: feedbackRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    List<Widget> commentWidgets = [];
                    Map<dynamic, dynamic> data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                    data.forEach((key, value) {
                      commentWidgets.add(
                        GestureDetector(
                          onTap: () {
                            _showUpdateDialog(context, key, value['comment'], value['moodRating']);
                          },
                          onLongPress: () {
                            _showDeleteDialog(context, key, value);
                          },
                          child: ListTile(
                            title: Text(value['comment']),
                            subtitle: Text('Mood Rating: ${value['moodRating']}'),
                            leading: Text('${DateTime.fromMillisecondsSinceEpoch(value['timestamp'])}'),
                          ),
                        ),
                      );
                    });
                    return ListView(
                      children: commentWidgets,
                    );
                  } else {
                    return const Text('No feedback available.');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, String key, String currentComment, int currentRating) {
    TextEditingController commentController = TextEditingController(text: currentComment);
    int rating = currentRating;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Feedback"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: commentController,
                decoration: const InputDecoration(labelText: "Comment"),
              ),
              const SizedBox(height: 16.0),
              const Text('Mood Rating:'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  for (int i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          rating = i;
                        });
                      },
                      child: Text(
                        _getMoodEmoji(i),
                        style: TextStyle(
                          fontSize: 24.0,
                          color: rating == i ? Colors.amber : Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                feedbackRef.child(key).update({
                  'comment': commentController.text,
                  'moodRating': rating,
                }).then((_) {
                  Fluttertoast.showToast(
                    msg: "Feedback updated successfully.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Failed to update feedback: $error");
                  Fluttertoast.showToast(
                    msg: "Failed to update feedback.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                });
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String key, dynamic value) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Timestamp: ${DateTime.fromMillisecondsSinceEpoch(value['timestamp'])}'),
              Text('Comment: ${value['comment']}'),
              Text('Mood Rating: ${value['moodRating']}'),
              const SizedBox(height: 16),
              const Text('Are you sure you want to delete this feedback?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                feedbackRef.child(key).remove().then((_) {
                  Fluttertoast.showToast(
                    msg: "Feedback deleted successfully.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  Navigator.of(context).pop();
                }).catchError((error) {
                  print("Failed to delete feedback: $error");
                  Fluttertoast.showToast(
                    msg: "Failed to delete feedback.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                });
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _submitFeedback(BuildContext context, User? user) {
    String comment = _commentController.text;
    if (comment.isEmpty || _moodRating == 0) {
      Fluttertoast.showToast(
        msg: "Please fill all fields.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    feedbackRef.push().set({
      'uid': user?.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'comment': comment,
      'moodRating': _moodRating,
    }).then((_) {
      Fluttertoast.showToast(
        msg: "Feedback submitted successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      _commentController.clear();
      setState(() {
        _moodRating = 0;
      });
    }).catchError((error) {
      print("Failed to submit feedback: $error");
      Fluttertoast.showToast(
        msg: "Failed to submit feedback.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  String _getMoodEmoji(int moodRating) {
    switch (moodRating) {
      case 1:
        return '😢';
      case 2:
        return '😞';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '';
    }
  }
}
