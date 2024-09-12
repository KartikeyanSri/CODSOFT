import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';


void main() => runApp(QuoteApp());

class QuoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Quote of the Day',
    theme: ThemeData(
    primarySwatch: Colors.blue,

        appBarTheme: AppBarTheme(centerTitle: true),
    ),
    home: QuoteHomePage(),
    );
  }
}

class QuoteHomePage extends StatefulWidget {
  @override
  _QuoteHomePageState createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> {
  final String _apiKey = 'aRTpxenfioOz6DfRj70D+w==YBawL1I9ItForDEC'; // Replace with your actual API key
  final String _baseUrl = 'https://api.api-ninjas.com/v1/quotes';

  String _quote = 'Fetching quote...';
  List<String> _favoriteQuotes = [];
  bool _isLoading = false; // Flag for loading indicator

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _fetchQuotes();
  }

  Future<void> _fetchQuotes() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(_baseUrl );
    final headers = {'X-Api-Key': _apiKey};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
    final
    quote = data[0]['quote'];
    setState(() {
    _quote = quote;
    _isLoading = false;
    });
    } else {
    setState(() {
    _isLoading = false;
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text('Failed to fetch quote: ${response.statusCode}'),
    ),
    );
    });
    }
    } on Exception catch (e) {
    setState(() {
    _isLoading = false;
    });
    print('Error fetching quotes: $e');
    }
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteQuotes = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _saveFavorite(String quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteQuotes.add(quote);
    });
    await prefs.setStringList('favorites', _favoriteQuotes);
  }

  void _shareQuote() {
    Share.share(_quote);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Quote of the Day'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),

              onPressed: _fetchQuotes,
            ),
          ],
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                if (_isLoading) CircularProgressIndicator(),
        Text(
          _quote,
          style: TextStyle(fontSize: 28, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ElevatedButton(

            onPressed:() => _saveFavorite(_quote),
    child: Text('Add to Favorites'),
    ),
    SizedBox(width: 10),
    ElevatedButton(
    onPressed: _shareQuote,
    child: Text('Share Quote'),
    ),
    ],
    ),
    SizedBox(height: 20),
    Text(
    'Favorites:',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    Expanded(
    child: ListView.builder(
    itemCount: _favoriteQuotes.length,

    itemBuilder: (context, index) {
    return ListTile(
    title: Text(_favoriteQuotes[index]),
    );
    },
    ),
    )
    ],
    ),
    ),
    );
  }
}