import 'dart:convert';
import 'dart:typed_data';

class ProjectImageData {
  const ProjectImageData({
    required this.id,
    required this.name,
    required this.dataUrl,
  });

  final String id;
  final String name;
  final String dataUrl;

  Uint8List? decodeBytes() {
    try {
      final commaIndex = dataUrl.indexOf(',');
      final payload = commaIndex >= 0
          ? dataUrl.substring(commaIndex + 1)
          : dataUrl;
      if (payload.trim().isEmpty) return null;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'dataUrl': dataUrl,
    };
  }

  factory ProjectImageData.fromJson(dynamic raw, int index) {
    if (raw is String) {
      return ProjectImageData(
        id: 'legacy-image-$index',
        name: 'Screenshot ${index + 1}',
        dataUrl: raw,
      );
    }

    if (raw is! Map) {
      return ProjectImageData(
        id: 'legacy-image-$index',
        name: 'Screenshot ${index + 1}',
        dataUrl: '',
      );
    }

    final json = Map<String, dynamic>.from(raw);
    final dataUrl = _firstString(
      json,
      const <String>[
        'dataUrl',
        'imageDataUrl',
        'base64Data',
        'src',
        'url',
      ],
    );

    return ProjectImageData(
      id: _firstString(json, const <String>['id']).isNotEmpty
          ? _firstString(json, const <String>['id'])
          : 'legacy-image-$index',
      name: _firstString(json, const <String>['name', 'imageName']).isNotEmpty
          ? _firstString(json, const <String>['name', 'imageName'])
          : 'Screenshot ${index + 1}',
      dataUrl: dataUrl,
    );
  }
}

class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.name,
    required this.details,
    required this.techStack,
    required this.liveUrl,
    required this.createdAt,
    required this.images,
  });

  final String id;
  final String name;
  final String details;
  final String techStack;
  final String liveUrl;
  final String createdAt;
  final List<ProjectImageData> images;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'details': details,
      'techStack': techStack,
      'liveUrl': liveUrl,
      'createdAt': createdAt,
      'images': images.map((image) => image.toJson()).toList(),
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] ?? json['screenshots'];
    final images = <ProjectImageData>[];

    if (rawImages is List) {
      for (var index = 0; index < rawImages.length; index++) {
        final image = ProjectImageData.fromJson(rawImages[index], index);
        if (image.dataUrl.trim().isNotEmpty) images.add(image);
      }
    }

    final legacyImage = _firstString(
      json,
      const <String>['imageDataUrl'],
    );
    if (images.isEmpty && legacyImage.isNotEmpty) {
      images.add(
        ProjectImageData(
          id: 'legacy-single-image',
          name: _firstString(json, const <String>['imageName']).isNotEmpty
              ? _firstString(json, const <String>['imageName'])
              : 'Project screenshot',
          dataUrl: legacyImage,
        ),
      );
    }

    final id = _firstString(json, const <String>['id']);
    final name = _firstString(json, const <String>['name']);
    final techStack = _firstString(
      json,
      const <String>['techStack', 'tech_stack'],
    );
    final createdAt = _firstString(
      json,
      const <String>['createdAt', 'created_at'],
    );

    return ProjectModel(
      id: id.isNotEmpty
          ? id
          : 'project-${DateTime.now().microsecondsSinceEpoch}',
      name: name.isNotEmpty ? name : 'Untitled Project',
      details: _firstString(
        json,
        const <String>['details', 'description'],
      ),
      techStack: techStack.isNotEmpty ? techStack : 'Custom Stack',
      liveUrl: _firstString(
        json,
        const <String>['liveUrl', 'live_url', 'url'],
      ),
      createdAt: createdAt.isNotEmpty ? createdAt : 'Saved locally',
      images: images,
    );
  }
}

String _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}
