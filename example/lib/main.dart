import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_qq/flutter_qq.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<File> _images = new List();
  String _output = '---';

  @override
  initState() {
    super.initState();
  }

  Future _chooseImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _images.add(image);
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
        if(qqResult.response==null){
          output = "登录成功qqResult.response==null";
          return;
        }
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
    // ShareQQContent shareContent = new ShareQQContent(
    //   shareType: SHARE_TO_QQ_TYPE.DEFAULT,
    //   title: "测试title",
    //   targetUrl: "https://www.baidu.com",
    //   summary: "测试summary",
    //   imageUrl: "http://inews.gtimg.com/newsapp_bt/0/876781763/1000",
    // );
    ShareQQContent shareContent = new ShareQQContent(
      shareType: SHARE_TO_QQ_TYPE.IMAGE,
      title: "测试title",
      targetUrl: "https://www.baidu.com",
      summary: "测试summary",
      imageLocalUrl: _images[0].path
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
      shareType: SHARE_TO_QZONE_TYPE.IMAGE_TEXT,
      title: "测试title",
      targetUrl: "https://www.baidu.com",
      summary: "测试summary",
      imageUrl: "http://inews.gtimg.com/newsapp_bt/0/876781763/1000",
    );
//     List<String> paths = new List();
//     for(File image in _images){
//       paths.add(image.path);
//     }
//     ShareQzoneContent shareContent = new ShareQzoneContent(
//       shareType: SHARE_TO_QZONE_TYPE.IMAGE,
//       title: "测试title",
//       targetUrl: "https://www.baidu.com",
//       summary: "测试summary",
//       imageUrls: paths,
//     );
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
    FlutterQq.registerQQ('1107493622');
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin QQ example app'),
        ),
        body: new Column(
          children: <Widget>[
            new Text(_output),
            new RaisedButton(
              onPressed: _chooseImage,
              child: new Text('chooseImage'),
            ),
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
          ],
        ),
      ),
    );
  }
}
