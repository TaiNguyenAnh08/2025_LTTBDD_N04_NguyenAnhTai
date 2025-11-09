import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wallpaperhub/data/api_key.dart';
import 'package:wallpaperhub/model/wallpaper_model.dart';
import 'package:wallpaperhub/views/image_view.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<WallpaperModel> wallpapers = [];
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  
  int pageNumber = 1;
  bool isLoading = false;
  String currentQuery = "";
  bool hasSearched = false;
  
  List<String> searchHistory = [];
  List<String> trendingSearches = [
    'Nature', 'Ocean', 'Mountains', 'City', 'Space', 'Abstract',
    'Sunset', 'Forest', 'Beach', 'Animals', 'Cars', 'Technology'
  ];

  searchWallpapers(String query, {bool newSearch = true}) async {
    if (isLoading || query.isEmpty) return;
    
    setState(() {
      isLoading = true;
      if (newSearch) {
        wallpapers.clear();
        pageNumber = 1;
        currentQuery = query;
        hasSearched = true;
        
        // Thêm vào lịch sử (không trùng)
        if (!searchHistory.contains(query)) {
          searchHistory.insert(0, query);
          if (searchHistory.length > 5) searchHistory.removeLast();
        }
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

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= 
          scrollController.position.maxScrollExtent - 200 && hasSearched) {
        searchWallpapers(currentQuery, newSearch: false);
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
        title: Text(
          'Search Wallpapers',
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
          child: Column(
            children: [
              // Search Bar lớn
              Container(
                margin: EdgeInsets.all(24),
                padding: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Color(0xfff5f8fd),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search for wallpapers...',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            searchWallpapers(value);
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (searchController.text.isNotEmpty) {
                          searchWallpapers(searchController.text);
                        }
                      },
                      child: Icon(Icons.search, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              
              // Nội dung
              Expanded(
                child: !hasSearched
                    ? SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search History
                            if (searchHistory.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Text(
                                  'Recent Searches',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              ...searchHistory.map((query) => ListTile(
                                leading: Icon(Icons.history, color: Colors.grey),
                                title: Text(query),
                                onTap: () {
                                  searchController.text = query;
                                  searchWallpapers(query);
                                },
                              )),
                              SizedBox(height: 16),
                            ],
                            
                            // Trending Searches
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Text(
                                'Trending Searches',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: trendingSearches.map((query) {
                                  return GestureDetector(
                                    onTap: () {
                                      searchController.text = query;
                                      searchWallpapers(query);
                                    },
                                    child: Chip(
                                      label: Text(query),
                                      backgroundColor: Color(0xfff5f8fd),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        controller: scrollController,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
