// OAPlayer, Powered by Luckykeeper <luckykeeper@luckykeeper.site | https://luckykeeper.site>
// last modified: 2023-06-10

import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';

import 'model/model.dart';
import 'videoViewer.dart';

void main() {
  initMeeduPlayer();
  runApp(MaterialApp(
    title: 'Navigation',
    home: MainApp(),
    theme: ThemeData(primarySwatch: Colors.cyan),
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // 初始化存储
  final Future<SharedPreferences> oaplayerPrefs =
      SharedPreferences.getInstance();
  late Future<String> gateway;
  late Future<String> token;

  // 输入框
  TextEditingController gatewayInput = TextEditingController();
  TextEditingController tokenInput = TextEditingController();

  @override
  initState() {
    super.initState();
    // 从存储中读取过往设置
    gateway = oaplayerPrefs.then((SharedPreferences prefs) {
      return prefs.getString("gateway") ?? "";
    }).then((value) => gatewayInput.text = value);
    token = oaplayerPrefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    }).then((value) => tokenInput.text = value);
  }

  // 保存设置
  saveSettings(String gatewayInput, String tokenInput) async {
    final SharedPreferences prefs = await oaplayerPrefs;
    prefs.setString("gateway", gatewayInput);
    prefs.setString("token", tokenInput);
  }

  // 网络请求 - 从 NoaHandler 获取播放列表
  Future<PlayList> getPlayList(String gateway, String token) async {
    // 包装请求
    HttpClient httpClient = HttpClient();
    String gatewayHostWithPort = gateway.split("/").first;
    String gatewayHost = gatewayHostWithPort.split(":").first;
    String gatewayPort = gatewayHostWithPort.split(":").last;
    String gatewayPath = gateway.substring(gatewayHostWithPort.length);
    // print("gatewayHost: " + gatewayHost);
    // print("gatewayPath: " + gatewayPath);
    // print("gatewayPort: " + gatewayPort);
    Map payLoad = {"token": token};
    Uri uri = Uri(
      scheme: "https",
      host: gatewayHost,
      path: gatewayPath,
      port: int.parse(gatewayPort),
    );
    HttpClientRequest request = await httpClient.postUrl(uri);
    request.headers.contentLength = utf8.encode(jsonEncode(payLoad)).length;
    request.headers.add("user-agent", "OAPlayer By Luckykeeper");
    request.headers.add("content-type", "application/json");
    request.add(utf8.encode(jsonEncode(payLoad)));
    HttpClientResponse response = await request.close();
    String responseBody = await response.transform(utf8.decoder).join();
    // print("resp:" + responseBody);
    var serverReturn = PlayList.fromJson(jsonDecode(responseBody));
    // print(serverReturn.statusCode);
    // print(serverReturn.statusString);
    // print(serverReturn.videoList);
    return serverReturn;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.cyan),
      home: Scaffold(
        appBar: AppBar(title: const Text("OAPlayer")),
        body: Center(
            child: Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    const Text(
                      "OAPlayer",
                      style: TextStyle(
                          color: Colors.cyan,
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Powered by Luckykeeper",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 100),
                        // decoration: BoxDecoration(
                        //   borderRadius: BorderRadius.circular(40),
                        //   border: Border.all(color: Colors.blue),
                        // ),
                        child: Column(
                          children: [
                            TextField(
                              decoration: const InputDecoration(
                                  labelText: "NoaHandler",
                                  hintText: "NoaHandler 网关地址",
                                  prefixIcon: Icon(Icons.dns)),
                              controller: gatewayInput,
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                  labelText: "Token",
                                  hintText: "NoaHandler 的对接 Token",
                                  prefixIcon: Icon(Icons.lock)),
                              controller: tokenInput,
                              obscureText: true,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 20),
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.sync),
                                label: const Text("保存Token并从网关拉取数据"),
                                onPressed: () {
                                  if (gatewayInput.text.isNotEmpty &&
                                      tokenInput.text.isNotEmpty) {
                                    saveSettings(
                                        gatewayInput.text, tokenInput.text);
                                    // PlayList? playList;
                                    () async {
                                      PlayList playList = await getPlayList(
                                          gatewayInput.text, tokenInput.text);
                                      if (playList.statusCode == 200) {
                                        // Main 里面上一级要套一层 MaterialApp
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) {
                                            return VideoViewer(
                                                videoList: playList.videoList);
                                          }),
                                        );
                                      }
                                      ;
                                    }();
                                  }
                                },
                              ),
                            )
                          ],
                        ))
                  ],
                ))),
      ),
    );
  }
}
