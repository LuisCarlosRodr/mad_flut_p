import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  final TextEditingController _commentController = TextEditingController(); // Form to insert data
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int _moodRating = 0;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
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
                      _submitFeedback(context, user);
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
            StreamBuilder(
              stream: FirebaseDatabase.instance.reference().child('feedback').onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Widget> commentWidgets = [];
                  Map<dynamic, dynamic>? data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                  if (data != null) {
                    data.forEach((key, value) {
                      commentWidgets.add(
                        LongPressDraggable(
                          data: key, // Utilizamos la clave como datos que se pasan al soltar
                          feedback: ListTile( // Widget que se muestra mientras se está arrastrando
                            title: Text(value['comment']),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              _showUpdateDialog(
                                context,
                                key,
                                value['comment'],
                                value['moodRating'],
                              );
                            },
                            onLongPress: () {
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
                                          // Delete feedback from Firebase
                                          DatabaseReference feedbackRef = FirebaseDatabase.instance.reference().child('feedback').child(key);
                                          feedbackRef.remove().then((_) {
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
                            },
                            child: ListTile(
                              title: Text(value['comment']),
                              subtitle: Text('Mood Rating: ${value['moodRating']}'),
                              leading: Text('${DateTime.fromMillisecondsSinceEpoch(value['timestamp'])}'),
                            ),
                          ),
                        ),
                      );
                    });
                  }
                  return Expanded(
                    child: ListView(
                      children: commentWidgets,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Update alertDialog
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
                // Update feedback in database
                DatabaseReference feedbackRef = FirebaseDatabase.instance.reference().child('feedback').child(key);
                feedbackRef.update({
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

  // Insert function in firebase
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
    DatabaseReference feedbackRef = FirebaseDatabase.instance.reference().child('feedback');
    feedbackRef.push().set({
      'uid': user?.uid,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'comment': comment,
      'moodRating': _moodRating,
    }).then((value) {
      Fluttertoast.showToast(
        msg: "Feedback submitted successfully.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
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

  // Original methods from StatelessWidget (unchanged)
  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Alert Dialog'),
          content: const Text('This is an alert dialog.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This is a SnackBar.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showToast() {
    Fluttertoast.showToast(
      msg: "This is a Toast.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _showModalBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Get link'),
              onTap: () => {},
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit name'),
              onTap: () => {},
            ),
          ],
        );
      },
    );
  }
}
