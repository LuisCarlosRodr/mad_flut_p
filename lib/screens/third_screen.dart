import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ThirdScreen extends StatelessWidget {
  const ThirdScreen({super.key});


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _showAlertDialog(context),
              child: const Text('Show AlertDialog'),
            ),
            ElevatedButton(
              onPressed: () => _showSnackBar(context),
              child: const Text('Show SnackBar'),
            ),
            ElevatedButton(
              onPressed: _showToast,
              child: const Text('Show Toast'),
            ),
            ElevatedButton(
              onPressed: () => _showModalBottomSheet(context),
              child: const Text('Show ModalBottomSheet'),
            ),
          ],
        ),
      ),
    );
  }
}