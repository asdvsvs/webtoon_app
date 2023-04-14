import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webtoon_app/models/webtoon_detail_model.dart';
import 'package:webtoon_app/models/webtoon_episo_model.dart';
import 'package:webtoon_app/services/api_services.dart';
import 'package:webtoon_app/widgets/episode_widget.dart';

class DetailScreen extends StatefulWidget {
  final String title, thumb, id;

  const DetailScreen({
    super.key,
    required this.title,
    required this.thumb,
    required this.id,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<WebtoonDetailModel> webtoon;
  late Future<List<WebtoonEpisodeMoodel>> episodes;
  late SharedPreferences prefs;
  bool isLiked = false;

  Future initPref() async {
    prefs = await SharedPreferences.getInstance();
    final likeToons = prefs.getStringList('likedTooons');
    if (likeToons != null) {
      if (likeToons.contains(widget.id) == true) {
        setState(() {
          isLiked = true;
        });
      }
    } else {
      await prefs.setStringList('likedToons', []);
    }
  }

  @override
  void initState() {
    super.initState();
    webtoon = ApiService.getToonById(widget.id);
    episodes = ApiService.getLatestEpisodesById(widget.id);
    initPref();
  }

  onHeartTap() async {
    final likeToons = prefs.getStringList('likedTooons');
    if (likeToons != null) {
      if (isLiked) {
        likeToons.remove(widget.id);
      } else {
        likeToons.add(widget.id);
      }
      await prefs.setStringList('likedToons', likeToons);
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.green,
        actions: [
          IconButton(
            onPressed: onHeartTap,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_outline_rounded,
            ),
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Hero(
                  tag: widget.id,
                  child: Container(
                    width: 250,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            offset: const Offset(0, 0),
                            color: Colors.black.withOpacity(0.5),
                          )
                        ]),
                    child: Image.network(
                      widget.thumb,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 25,
            ),
            FutureBuilder(
              future: webtoon,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        snapshot.data!.about,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        '${snapshot.data!.genre} / ${snapshot.data!.age}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }
                return const Text("...");
              },
            ),
            const SizedBox(
              height: 25,
            ),
            FutureBuilder(
              future: episodes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    children: [
                      for (var episode in snapshot.data!.length > 10
                          ? snapshot.data!.sublist(0, 10)
                          : snapshot.data!)
                        Episode(episode: episode, webtoonId: widget.id),
                    ],
                  );
                }
                return Container();
              },
            )
          ]),
        ),
      ),
    );
  }
}
