import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

const api = 'https://development.api.kayamoola.co.za';
const casinoApi = api + '/casino/games?brand_id=KAYAMOOLA_CO_ZA';
const launchDemo = api + '/casino/launch-demo/';
const siteUrl = 'https://development.kayamoola.co.za';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String gameUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: Casino(casinoUrl: gameUrl, notify: refresh)));
  }

  refresh(url) {
    setState(() {
      gameUrl = url;
    });
  }
}

class Grid extends StatelessWidget {
  Grid({Key? key, required this.selectGame}) : super(key: key);

  late Future<List<Banner>> banners = fetchBanners();
  final Function selectGame;

  void _incrementCounter(Banner i) async {
    log('${i.id}');
    final response =
        await http.get(Uri.parse(launchDemo + '${i.id}' + '?mobile=true'));

    if (response.statusCode == 200) {
      final raw = jsonDecode(response.body);
      var url = raw['url'] as String;
      log(url);
      selectGame(url);
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Banner>>(
        future: banners,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              itemCount: snapshot.data!.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (context, index) {
                return GridTile(
                    // child: Image.network(snapshot.data![index].image),
                    child: InkResponse(
                  child: Image.network(snapshot.data![index].image),
                  onTap: () => _incrementCounter(snapshot.data![index]),
                ));
              },
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          return const CircularProgressIndicator();
        });
  }

  Future<List<Banner>> fetchBanners() async {
    final response = await http.get(Uri.parse(casinoApi));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      final raw = jsonDecode(response.body);
      var games = raw['casino_games'] as List<dynamic>;
      var cut = games.sublist(1, 6);
      return cut.map((banner) => Banner.fromJson(banner)).toList();
    } else {
      throw Exception('Failed to load album');
    }
  }
}

class TextWidget extends StatelessWidget {
  const TextWidget({Key? key, required this.casinoUrl}) : super(key: key);
  final String casinoUrl;

  @override
  Widget build(BuildContext context) {
    return WebView(
      key: UniqueKey(),
      initialUrl: casinoUrl,
      javascriptMode: JavascriptMode.unrestricted,
    );

    // Uri.dataFromString(
    //             '<html><body><iframe width="424" height="238" src="$casinoUrl"></iframe></body></html>',
    //             mimeType: 'text/html')
    //         .toString(),
  }
}

class Casino extends StatelessWidget {
  // final Function() notifyParent;
  const Casino({Key? key, required this.casinoUrl, required this.notify})
      : super(key: key);
  final String casinoUrl;
  final Function notify;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Grid(selectGame: notify)),
        Expanded(child: TextWidget(casinoUrl: casinoUrl))
      ],
    );
  }
}

class Banner {
  final String name;
  final int id;
  final String image;
  final String slug;

  const Banner({
    required this.name,
    required this.id,
    required this.image,
    required this.slug,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      name: json['name'],
      id: json['id'],
      image: siteUrl + json['image'],
      slug: json['url_slug'],
    );
  }
}


//     Widget: Container(
// child: WebView(
//   initialUrl: Uri.dataFromString('<html><body><iframe src="https://www.youtube.com/embed/abc"></iframe></body></html>', mimeType: 'text/html').toString(),
//   javascriptMode: JavascriptMode.unrestricted,
// )),

// floatingActionButton: FloatingActionButton(
//   onPressed: _incrementCounter,
//   tooltip: 'Increment',
//   child: const Icon(Icons.add),
// ), // This trailing comma makes auto-formatting nicer for build methods
