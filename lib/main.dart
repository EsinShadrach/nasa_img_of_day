import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nasa_img_of_day/api/picture_of_day.dart';
import 'package:nasa_img_of_day/image_loading.dart';
import 'package:nasa_img_of_day/models/data_model.dart';
import 'package:nasa_img_of_day/utils/get_most_prominent_color.dart';
import 'package:nasa_img_of_day/utils/build_context_extensions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// the key being the url and the color being what we need
  /// if the url is not in the map, we fetch the color
  /// if the url is in the map, we use the color
  Map<String, Color> colors = {};
  int presentPage = 0;
  Color? mostProminentColor;
  bool isLoading = true;
  String? hasErroMsg;
  List<PictureOfTheDay> pictures = [];
  int _retryCount = 0;

  @override
  void initState() {
    _handleFetchPicOfDay();
    super.initState();
  }

  Future<List<PictureOfTheDay>> _handleFetchPicOfDay() async {
    try {
      final response = await GetPicOfDay().getPicOfDay();

      setState(() {
        isLoading = false;
      });

      if (response.isNotEmpty) {
        var hasHdurl = response
            .where(
              (element) => element.hdurl != null,
            )
            .toList();

        if (hasHdurl.isEmpty) {
          if (_retryCount < 3) {
            _retryCount++;
            return _handleFetchPicOfDay();
          }
        }

        final firstPic = hasHdurl.first;
        mostProminentColor =
            await _getMostProminentColorCached(firstPic.hdurl!);

        setState(() {
          pictures = response;
        });
      }

      return response;
    } catch (e) {
      setState(() {
        hasErroMsg = e.toString();
      });
      return [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Color> _getMostProminentColorCached(String imageUrl) async {
    if (colors.containsKey(imageUrl)) {
      return colors[imageUrl]!;
    } else {
      final color = await getMostProminentColor(imageUrl);
      colors[imageUrl] = color;
      return color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: mostProminentColor ?? context.colorScheme.primary,
          primary: mostProminentColor,
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Scaffold(
          floatingActionButton: Builder(builder: (inneContext) {
            return FloatingActionButton(
              backgroundColor: inneContext.colorScheme.primary,
              foregroundColor: inneContext.colorScheme.onPrimary,
              onPressed: () {
                //
              },
              child: const Icon(Icons.download_rounded),
            );
          }),
          backgroundColor: mostProminentColor ?? context.colorScheme.background,
          body: _handleDisplay(),
        ),
      ),
    );
  }

  Widget _handleDisplay() {
    debugPrint("page: $presentPage");
    if (isLoading) {
      return const ImageLoading();
    } else if (hasErroMsg != null) {
      return Center(
        child: Text(
          hasErroMsg!,
          style: context.textTheme.titleLarge,
        ),
      );
    } else {
      return PageView.builder(
        onPageChanged: (int page) {
          _updateMostProminentColor(page);
        },
        itemCount: pictures.length,
        itemBuilder: (context, index) {
          final pic = pictures[index];
          return Stack(
            children: [
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: pic.hdurl!,
                  placeholder: (context, url) => const ImageLoading(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    " ${presentPage + 1} / ${pictures.length}\n${pic.title.toString()}",
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineMedium!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _updateMostProminentColor(int page) async {
    setState(() {
      presentPage = page;
    });

    await _getMostProminentColorCached(pictures[page].hdurl!).then((value) {
      setState(() {
        mostProminentColor = value;
        debugPrint("mostProminentColor: $mostProminentColor");
      });
    });
  }
}
