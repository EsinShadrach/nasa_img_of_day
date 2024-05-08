import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nasa_img_of_day/api/api_constant.dart';
import 'package:nasa_img_of_day/models/data_model.dart';
import 'package:nasa_img_of_day/utils/memoizer.dart';

class GetPicOfDay {
  final _uri = Uri.parse(
    ApiConstant.url,
  );
  static final _memoizer = AsyncMemoizer<List<PictureOfTheDay>>();

  Future<List<PictureOfTheDay>> getPicOfDay() async {
    return _memoizer.runOnce(_fetchPicOfDay);
  }

  Future<List<PictureOfTheDay>> _fetchPicOfDay() async {
    final response = await http.get(_uri);

    if (response.statusCode == 200) {
      debugPrint('response.body: ${response.body}');
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => PictureOfTheDay.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load picture of the day');
    }
  }
}
