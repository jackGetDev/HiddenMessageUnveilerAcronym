import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(FlaskAPIApp());

class FlaskAPIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hidden Message Unveiler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(primary: Colors.green, secondary: Colors.green), 
       
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(primary: Colors.green, secondary: Colors.green), 
       
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _articleController = TextEditingController();
  List<String> _hiddenEnglishWords = [];

  Future<void> _getHiddenEnglishWords() async {
    final apiUrl = 'http://127.0.0.1:5000/extract_hidden_english_words';
    final headers = {'Content-Type': 'application/json'};
    final requestBody = jsonEncode({'article_text': _articleController.text});

    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: requestBody);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> hiddenEnglishWords = data['hidden_english_words'].cast<String>();
      setState(() {
        _hiddenEnglishWords = hiddenEnglishWords;
      });
    } else {
      setState(() {
        _hiddenEnglishWords = [];
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch hidden English words. Please try again later.'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hidden Message Unveiler')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _articleController,
              maxLines: 10,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Enter or paste the article',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.secondary),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getHiddenEnglishWords,
              style: ElevatedButton.styleFrom(
                primary: Theme.of(context).colorScheme.secondary,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text('Extract Hidden English Words'),
            ),
            SizedBox(height: 16),
            if (_hiddenEnglishWords.isNotEmpty)
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Hidden English Words:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    for (var word in _hiddenEnglishWords)
                      Text(word, style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
