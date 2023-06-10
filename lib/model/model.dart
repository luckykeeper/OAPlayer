class PlayList {
  int? statusCode;
  String? statusString;
  List<VideoList>? videoList;

  PlayList({this.statusCode, this.statusString, this.videoList});

  PlayList.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    statusString = json['StatusString'];
    if (json['VideoList'] != null) {
      videoList = <VideoList>[];
      json['VideoList'].forEach((v) {
        videoList!.add(new VideoList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['StatusString'] = this.statusString;
    if (this.videoList != null) {
      data['VideoList'] = this.videoList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class VideoList {
  String? videoName;
  String? videoUrl;

  VideoList({this.videoName, this.videoUrl});

  VideoList.fromJson(Map<String, dynamic> json) {
    videoName = json['videoName'];
    videoUrl = json['videoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['videoName'] = this.videoName;
    data['videoUrl'] = this.videoUrl;
    return data;
  }
}
