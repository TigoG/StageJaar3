class GuidePageModel {
  final String page;
  final GuideImageModel? image;
  final GuideContentModel content;
  final int? pageIndicator;

  GuidePageModel({
    required this.page,
    this.image,
    required this.content,
    this.pageIndicator,
  });

  factory GuidePageModel.fromJson(Map<String, dynamic> json) {
    return GuidePageModel(
      page: json['page'] as String,
      image: json['image'] != null ? GuideImageModel.fromJson(json['image']) : null,
      content: GuideContentModel.fromJson(json['content']),
      pageIndicator: json['pageIndicator'] as int?,
    );
  }
}

class GuideImageModel {
  final String? assetPath;

  GuideImageModel({this.assetPath});

  factory GuideImageModel.fromJson(Map<String, dynamic> json) {
    return GuideImageModel(
      assetPath: json['assetPath'] as String?,
    );
  }
}

class GuideContentModel {
  final String title;
  final String description;

  GuideContentModel({
    required this.title,
    required this.description,
  });

  factory GuideContentModel.fromJson(Map<String, dynamic> json) {
    return GuideContentModel(
      title: json['title'] as String,
      description: json['description'] as String,
    );
  }
}
