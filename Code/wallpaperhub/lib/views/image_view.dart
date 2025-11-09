import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'dart:typed_data';

import 'dart:html' as html show AnchorElement, Blob, Url if (dart.library.io) 'dart:io';

class ImageView extends StatefulWidget {
  final String imgUrl;
  
  const ImageView({super.key, required this.imgUrl});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  
  Future<void> downloadImage() async {
    try {
      final response = await http.get(Uri.parse(widget.imgUrl));
      final Uint8List bytes = response.bodyBytes;
      
      if (kIsWeb) {
        // Download cho Web
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', 'wallpaper.jpg')
          ..click();
        html.Url.revokeObjectUrl(url);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Downloading...')),
          );
        }
      } else {
        // Cho mobile (Android/iOS) - Hiện thông báo tạm
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download feature coming soon for mobile!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0.0,
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              child: Image.network(
                widget.imgUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: downloadImage,
                icon: Icon(Icons.download),
                label: Text('Download Wallpaper'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
