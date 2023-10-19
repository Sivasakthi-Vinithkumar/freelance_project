import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart'; // Import the HTML package
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final List<int> ids;
  final int id;

  DetailScreen({required this.ids, required this.id});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<String> detailContentList = [];
  List<String> titleContentList = [];
  int currentIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDetailData(widget.id);
  }

  Future<void> fetchDetailData(int id) async {
    final response = await http.get(Uri.parse('https://demo.athemes.com/wp-json/wp/v2/posts/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final content = data['content']['rendered'];
      final title = data['title']['rendered'];

      setState(() {
        detailContentList.add(content);
        titleContentList.add(title);
        isLoading = false;
        fetchRemainingDetailData();
      });
    } else {
      throw Exception('Failed to load detail');
    }
  }

  Future<void> fetchRemainingDetailData() async {
    for (int id in widget.ids) {
      if (id == widget.id) continue;

      final response = await http.get(Uri.parse('https://demo.athemes.com/wp-json/wp/v2/posts/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content']['rendered'];
        final title = data['title']['rendered'];

        setState(() {
          detailContentList.add(content);
          titleContentList.add(title);
        });
      } else {
        throw Exception('Failed to load detail');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isLoading
            ? Text("Loading...")
            : Text(currentIndex < titleContentList.length
            ? titleContentList[currentIndex]
            : "Loading..."),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : CarouselSlider(
        items: List<Widget>.generate(widget.ids.length, (index) {
          return Card(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (index < titleContentList.length)
                    Html(
                      data: titleContentList[index],
                      style: {
                        "body": Style(
                          fontSize: FontSize(24),
                          margin: EdgeInsets.all(0),
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700
                        ),
                      },
                    ),
                  if (index < detailContentList.length)
                    Html(
                      data: detailContentList[index],
                      style: {
                        "p": Style(
                          fontSize: FontSize(14),
                          margin: EdgeInsets.all(0),
                        ),
                      },
                    ),
                ],
              ),
            ),
          );
        }),
        options: CarouselOptions(
          enableInfiniteScroll: false,
          height: double.maxFinite,
          enlargeCenterPage: true,
          onPageChanged: (index, reason) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }

}



