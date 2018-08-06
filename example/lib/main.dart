import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_qq/flutter_qq.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _output = '---';

  @override
  initState() {
    super.initState();
  }

  Future<Null> _handleisQQInstalled() async {
    var result = await FlutterQq.isQQInstalled();
    var output;
    if (result) {
      output = "QQ已安装";
    } else {
      output = "QQ未安装";
    }
    setState(() {
      _output = output;
    });
  }

  Future<Null> _handleLogin() async {
    try {
      var qqResult = await FlutterQq.login();
      var output;
      if (qqResult.code == 0) {
        output = "登录成功" + qqResult.response.toString();
      } else {
        output = "登录失败" + qqResult.message;
      }
      setState(() {
        _output = output;
      });
    } catch (error) {
      print("flutter_plugin_qq_example:" + error.toString());
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
      var output;
      if (qqResult.code == 0) {
        output = "分享成功";
      } else if (qqResult.code == 1) {
        output = "分享失败" + qqResult.message;
      } else {
        output = "用户取消";
      }
      setState(() {
        _output = output;
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
      var output;
      if (qqResult.code == 0) {
        output = "分享成功";
      } else if (qqResult.code == 1) {
        output = "分享失败" + qqResult.message;
      } else {
        output = "用户取消";
      }
      setState(() {
        _output = output;
      });
    } catch (error) {
      print("flutter_plugin_qq_example:" + error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    FlutterQq.registerQQ('101435528');
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin QQ example app'),
        ),
        body: new Column(
          children: <Widget>[
            new RaisedButton(
              onPressed: _handleisQQInstalled,
              child: new Text('isQQInstalled'),
            ),
            new RaisedButton(
              onPressed: _handleLogin,
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
