import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qq/flutter_qq.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = 'Unknown';

  @override
  initState() {
    super.initState();
  }

  Future<Null> _handleSignIn() async {
    try {
      try {
        var qqResult = await FlutterQq.login();
        setState(() {
          _output = qqResult.message;
        });
      } catch (error) {
        print("flutter_plugin_qq_example:" + error.toString());
      }
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleShareToQQ() async {
    ShareQQContent shareContent = new ShareQQContent(
      title: "测试title",
      targetUrl: "https://www.baidu.com",
      summary: "测试summary",
      imageUrl: "http://inews.gtimg.com/newsapp_bt/0/876781763/1000",
    );
    try {
      var qqResult = await FlutterQq.shareToQQ(shareContent);
      setState(() {
        _output = qqResult.message;
      });
    } catch (error) {
      print("flutter_plugin_qq_example:" + error.toString());
    }
  }

  Future<Null> _handleShareToQZone() async {
    ShareQzoneContent shareContent = new ShareQzoneContent(
      title: "测试title",
      targetUrl: "https://www.baidu.com",
      summary: "测试summary",
      imageUrls: ["http://inews.gtimg.com/newsapp_bt/0/876781763/1000"],
    );
    try {
      var qqResult = await FlutterQq.shareToQzone(shareContent);
      setState(() {
        _output = qqResult.message;
      });
    } catch (error) {
      print("flutter_plugin_qq_example:" + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterQq.registerQq('101435528');
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Column(
          children: <Widget>[
            new RaisedButton(
              onPressed: _handleSignIn,
              child: new Text('login'),
            ),
            new RaisedButton(
              onPressed: _handleShareToQQ,
              child: new Text('ShareToQQ'),
            ),
            new RaisedButton(
              onPressed: _handleShareToQZone,
              child: new Text('ShareToQZone'),
            ),
            new Text(_output),
          ],
        ),
      ),
    );
  }
}
