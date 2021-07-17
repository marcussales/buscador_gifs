import 'dart:convert';
import 'package:buscador_gifs/ui/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _search;
  int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;
    if (_search == null || _search.isEmpty)
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=T9A81EwJZAHN9GUXSfCQtJbkVY32kKLs&limit=24&rating=g");
    else {
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=T9A81EwJZAHN9GUXSfCQtJbkVY32kKLs&q=$_search&limit=25&offset=$_offset&rating=g&lang=en");
    }
    return json.decode(response.body);
  }

  getCount(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.black,
            title: Image.network(
                "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
            centerTitle: true),
        backgroundColor: Colors.black,
        body: Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: "Pesquise seu GIF aqui",
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder()
                  ),
              style: TextStyle(color: Colors.white, fontSize: 18.0),
              textAlign: TextAlign.center,
              onSubmitted: (text) {
                setState(() {
                  _offset = 0;
                  _search = text;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getGifs(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Container(
                        width: 400.0,
                        height: 400.0,
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 5.0,
                        ));
                  default:
                    if (snapshot.hasError) {
                      return Container(
                          child: Text(
                              "Ocorreu um erro, reinicie o buscador de GIFS"));
                    } else
                      return _createGifTable(context, snapshot);
                }
              },
            ),
          )
        ]));
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, mainAxisSpacing: 10.0, crossAxisSpacing: 10.0),
        itemCount: getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          if (_search == null || index < snapshot.data["data"].length)
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                  height: 300.0,
                  fit: BoxFit.cover),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data['data'][index])));
              },
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]
                    ["fixed_height"]["url"]);
              },
            );
          else
            return Container(
              child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle, color: Colors.white, size: 60.0),
                      Text('Carregar mais GIFS',
                          style: TextStyle(color: Colors.white, fontSize: 20.0))
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _offset += _offset;
                    });
                  }),
            );
        });
  }
}
