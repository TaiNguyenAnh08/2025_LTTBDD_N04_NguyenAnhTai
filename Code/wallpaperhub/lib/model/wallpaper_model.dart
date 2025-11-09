class WallpaperModel {
  String? photographer;
  String? photographerUrl;
  int? photographerId;
  SrcModel? src;

  WallpaperModel({
    this.photographer,
    this.photographerUrl,
    this.photographerId,
    this.src,
  });

  factory WallpaperModel.fromMap(Map<String, dynamic> jsonData) {
    return WallpaperModel(
      photographer: jsonData["photographer"],
      photographerUrl: jsonData["photographer_url"],
      photographerId: jsonData["photographer_id"],
      src: SrcModel.fromMap(jsonData["src"]),
    );
  }
}

class SrcModel {
  String? original;
  String? small;
  String? portrait;
  String? large2x;

  SrcModel({this.original, this.small, this.portrait, this.large2x});

  factory SrcModel.fromMap(Map<String, dynamic> jsonData) {
    return SrcModel(
      original: jsonData["original"],
      small: jsonData["small"],
      portrait: jsonData["portrait"],
      large2x: jsonData["large2x"],
    );
  }
}
