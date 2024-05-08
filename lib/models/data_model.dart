class PictureOfTheDay {
  String? title;
  String? explanation;
  String? url;
  String? hdurl;
  String? date;
  String? mediaType;
  String? serviceVersion;
  String? copyRight;

  PictureOfTheDay({
    required this.title,
    required this.explanation,
    required this.url,
    required this.hdurl,
    required this.date,
    required this.mediaType,
    required this.serviceVersion,
    this.copyRight,
  });

  factory PictureOfTheDay.fromJson(Map<String, dynamic> json) {
    return PictureOfTheDay(
      title: json['title'],
      explanation: json['explanation'],
      url: json['url'],
      hdurl: json['hdurl'],
      date: json['date'],
      mediaType: json['media_type'],
      serviceVersion: json['service_version'],
      copyRight: json['copyRight'],
    );
  }
}
