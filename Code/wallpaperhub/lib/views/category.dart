import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperhub/data/api_key.dart';
import 'package:wallpaperhub/model/wallpaper_model.dart';
import 'package:wallpaperhub/views/image_view.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  
  const CategoryPage({super.key, required this.categoryName});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<WallpaperModel> wallpapers = [];
  ScrollController scrollController = ScrollController();
  int pageNumber = 1;
  bool isLoading = false;

  getCategoryWallpapers({bool loadMore = false}) async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });
    
    var response = await http.get(
      Uri.parse("https://api.pexels.com/v1/search?query=${widget.categoryName}&per_page=15&page=$pageNumber"),
      headers: {"Authorization": apiKey},
    );

    Map<String, dynamic> jsonData = jsonDecode(response.body);
    jsonData["photos"].forEach((element) {
      WallpaperModel wallpaperModel = WallpaperModel.fromMap(element);
      wallpapers.add(wallpaperModel);
    });

    setState(() {
      isLoading = false;
      pageNumber++;
    });
  }

  @override
  void initState() {
    getCategoryWallpapers();
    
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        getCategoryWallpapers(loadMore: true);
      }
    });
    
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} Wallpapers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6.0,
                    crossAxisSpacing: 6.0,
                    childAspectRatio: 0.6,
                    children: wallpapers.map((wallpaper) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageView(
                                imgUrl: wallpaper.src!.large2x ?? wallpaper.src!.portrait!,
                              ),
                            ),
                          );
                        },
                        child: GridTile(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              wallpaper.src!.portrait!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (isLoading)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
