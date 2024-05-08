import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

Future<Color> getMostProminentColor(String imageUrl) async {
  debugPrint('imageUrl: $imageUrl');

  final http.Response response = await http.get(
    Uri.parse(imageUrl),
  );

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    final image = img.decodeImage(bytes);
    if (image != null) {
      final histogram = getHistogram(image);
      final mostProminentColor = getMostProminentColorFromHistogram(histogram);
      return Color(mostProminentColor);
    }
  }

  return Colors.grey;
}

Map<int, int> getHistogram(img.Image image) {
  final histogram = <int, int>{};
  var imageData = image.data;

  if (imageData == null || imageData.isEmpty) {
    return histogram;
  }

  for (final img.Pixel pixel in imageData) {
    if (pixel.isValid) {
      final color = (pixel.a.toInt() << 24) |
          (pixel.r.toInt() << 16) |
          (pixel.g.toInt() << 8) |
          pixel.b.toInt();
      histogram[color] = (histogram[color] ?? 0) + 1;
    }
  }

  return histogram;
}

int getMostProminentColorFromHistogram(Map<int, int> histogram) {
  int maxCount = 0;
  int mostProminentColor = 0;

  histogram.forEach((color, count) {
    if (count > maxCount) {
      maxCount = count;
      mostProminentColor = color;
    }
  });

  return mostProminentColor;
}
