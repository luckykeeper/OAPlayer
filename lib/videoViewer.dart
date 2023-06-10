// OAPlayer 视频播放页面

import 'package:flutter/material.dart';
import 'model/model.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({
    super.key,
    required this.videoList,
  });
  final List<VideoList>? videoList;

  @override
  State<VideoViewer> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoViewer> {
  final _meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
    colorTheme: Colors.cyanAccent,
    fits: [BoxFit.scaleDown],
    screenManager: const ScreenManager(forceLandScapeInFullscreen: true),
  );
  // StreamSubscription _playerEventSubs;

  List<String> videoUrl = [];
  List<String> videoName = [];
  late int nowPlayingIndex;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Wakelock.enable();
    // 临时跳过第【0】个，源有问题，需要给后端加一个屏蔽部分资源的功能
    // NoaHandler / OADrive 需要更改
    // 仅Windows播放问题
    nowPlayingIndex = 0;
    if (widget.videoList!.isNotEmpty) {
      for (var i = 0; i < widget.videoList!.length; i++) {
        // print(widget.videoList![i].videoUrl);
        videoUrl.add(widget.videoList![i].videoUrl!);
        videoName.add(widget.videoList![i].videoName!);
      }
    }
    // print(videoUrl);
    // 初始化播放器
    _meeduPlayerController.header = Text(
      videoName[0],
      style: const TextStyle(color: Colors.pinkAccent),
    );
    _meeduPlayerController.setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: videoUrl[nowPlayingIndex],
        // source: videoUrl[nowPlayingIndex],
      ),
      autoplay: true,
    );

    // 强制触发一次缩放
    _meeduPlayerController.toggleVideoFit();

    _meeduPlayerController.onPlayerStatusChanged.listen((PlayerStatus status) {
      if (status == PlayerStatus.completed) {
        // 判断是否循环播放完一圈
        if (nowPlayingIndex == videoUrl.length - 1) {
          nowPlayingIndex = 0;
        } else {
          // print("nowPlayingIndex:" + nowPlayingIndex.toString());
          nowPlayingIndex += 1;
        }
        _meeduPlayerController.header = Text(
          videoName[nowPlayingIndex],
          style: const TextStyle(color: Colors.pinkAccent),
        );

        _meeduPlayerController.setDataSource(
          DataSource(
            type: DataSourceType.network,
            source: videoUrl[nowPlayingIndex],
          ),
          autoplay: true,
        );
      }
    });
  }

  @override
  void dispose() {
    Wakelock.disable(); // if you are using wakelock
    _meeduPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OAPlayer - 播放页"),
      ),
      body: SafeArea(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: MeeduVideoPlayer(
            controller: _meeduPlayerController,
          ),
        ),
      ),
    );
  }
}
