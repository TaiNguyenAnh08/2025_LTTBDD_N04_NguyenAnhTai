import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperhub/data/data.dart';
import 'package:wallpaperhub/data/api_key.dart';
import 'package:wallpaperhub/model/categories_model.dart';
import 'package:wallpaperhub/model/wallpaper_model.dart';
import 'package:wallpaperhub/views/widgets/widget.dart';
import 'package:wallpaperhub/views/image_view.dart';
import 'package:wallpaperhub/views/category.dart';
import 'package:wallpaperhub/views/search.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoriesModel> categories = [];
  List<WallpaperModel> wallpapers = [];
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  
  int pageNumber = 1;
  bool isLoading = false;
  String currentQuery = "";
  bool isSearchMode = false;
  bool showScrollToTop = false;
  
  // Gợi ý từ khóa
  List<String> searchSuggestions = [
    'Nature', 'City', 'Cars', 'Bikes', 'Animals', 'Beach', 
    'Mountains', 'Forest', 'Ocean', 'Sunset', 'Space', 'Abstract'
  ];
  List<String> filteredSuggestions = [];
  bool showSuggestions = false;

  getTrendingWallpapers() async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
    });
    
    var response = await http.get(
      Uri.parse("https://api.pexels.com/v1/curated?per_page=15&page=$pageNumber"),
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

  searchWallpapers(String query, {bool newSearch = true}) async {
    if (isLoading) return;
    
    setState(() {
      isLoading = true;
      if (newSearch) {
        wallpapers.clear();
        pageNumber = 1;
        currentQuery = query;
        isSearchMode = true;
      }
    });
    
    var response = await http.get(
      Uri.parse("https://api.pexels.com/v1/search?query=$query&per_page=15&page=$pageNumber"),
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
  
  void loadMore() {
    if (isSearchMode && currentQuery.isNotEmpty) {
      searchWallpapers(currentQuery, newSearch: false);
    } else {
      getTrendingWallpapers();
    }
  }
  
  void filterSuggestions(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredSuggestions = [];
        showSuggestions = false;
      } else {
        filteredSuggestions = searchSuggestions
            .where((suggestion) => 
                suggestion.toLowerCase().contains(query.toLowerCase()))
            .toList();
        showSuggestions = filteredSuggestions.isNotEmpty;
      }
    });
  }

  @override
  void initState() {
    categories = getCategories();
    getTrendingWallpapers();
    
    // Thêm listener cho scroll
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200) {
        loadMore();
      }
    });
    
    super.initState();
  }
  
  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: brandName(),
        ),
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      // Search bar
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 24),
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: Color(0xfff5f8fd),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                decoration: InputDecoration(
                                  hintText: 'search wallpaper',
                                  border: InputBorder.none,
                                ),
                                onChanged: (value) {
                                  filterSuggestions(value);
                                },
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    searchWallpapers(value);
                                    setState(() {
                                      showSuggestions = false;
                                    });
                                  }
                                },
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchPage(),
                                  ),
                                );
                              },
                              child: Icon(Icons.search),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
              // Categories
              Container(
                height: 80,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return CategoriesTile(
                      title: categories[index].categoryName!,
                      imgUrl: categories[index].imgUrl!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategoryPage(
                              categoryName: categories[index].categoryName!,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              // Wallpapers Grid
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
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
              ),
              // Loading indicator
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
              // Search suggestions
              if (showSuggestions)
                Positioned(
                  top: 70,
                  left: 24,
                  right: 24,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredSuggestions.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.search, size: 20),
                            title: Text(filteredSuggestions[index]),
                            onTap: () {
                              searchController.text = filteredSuggestions[index];
                              searchWallpapers(filteredSuggestions[index]);
                              setState(() {
                                showSuggestions = false;
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoriesTile extends StatelessWidget {
  final String imgUrl, title;
  final Function onTap;
  
  CategoriesTile({
    required this.title, 
    required this.imgUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(right: 8),
        child: Stack(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imgUrl,
                height: 80,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              height: 80,
              width: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.black26,
              ),
              alignment: Alignment.center,
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
