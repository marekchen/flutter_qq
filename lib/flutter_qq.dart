import 'dart:async';

import 'package:flutter/services.dart';

enum SHARE_TO_QQ_TYPE {
  DEFAULT, //1
  AUDIO, //2
  IMAGE, //5
  APP //6
}

enum SHARE_TO_QZONE_TYPE {
  IMAGE_TEXT, //1
  PUBLISH_MOOD, //3 说说
  PUBLISH_VIDEO, //4 视频
  IMAGE, //5, 貌似QQ不再支持
  APP //6
}

enum QZONE_FLAG {
  DEFAULT, //0
  AUTO_OPEN, //1
  ITEM_HIDE //2
}

class ShareQQContent {
  SHARE_TO_QQ_TYPE shareType;
  String title;
  String targetUrl;
  String summary;

  String imageUrl;
  String imageLocalUrl;

  String appName;
  String audioUrl;

  QZONE_FLAG qzoneFlag;

  String ark;

  ShareQQContent({
    this.shareType = SHARE_TO_QQ_TYPE.DEFAULT,
    this.title,
    this.targetUrl,
    this.summary,
    this.imageUrl,
    this.imageLocalUrl,
    this.appName,
    this.audioUrl,
    this.qzoneFlag = QZONE_FLAG.DEFAULT,
    this.ark,
  });
}

class ShareQzoneContent {
  SHARE_TO_QZONE_TYPE shareType;
  String title;
  String targetUrl;
  String summary;
  String imageUrl;
  List<String> imageUrls;

  String scene;
  String callback;

  ShareQzoneContent({
    this.shareType = SHARE_TO_QZONE_TYPE.IMAGE_TEXT,
    this.title,
    this.targetUrl,
    this.summary,
    this.imageUrl,
    this.imageUrls,
    this.scene,
    this.callback,
  });
}

class QQResult {
  int code;
  String message;
  Map<dynamic, dynamic> response;
}

class FlutterQq {
  static const MethodChannel _channel = const MethodChannel('flutter_qq');

  static void registerQQ(String appId) async {
    await _channel.invokeMethod('registerQQ', {'appId': appId});
  }

  static Future<bool> isQQInstalled() async {
    return await _channel.invokeMethod('isQQInstalled');
  }

  static Future<QQResult> login() async {
    final Map<dynamic, dynamic> result = await _channel.invokeMethod('login');
    QQResult qqResult = new QQResult();
    qqResult.code = result["Code"];
    qqResult.message = result["Message"];
    qqResult.response = result["Response"];
    return qqResult;
  }

  static Future<QQResult> shareToQQ(ShareQQContent shareContent) async {
    Map<String, dynamic> params;
    int shareType = 1;
    switch (shareContent.shareType) {
      case SHARE_TO_QQ_TYPE.AUDIO:
        shareType = 2;
        break;
      case SHARE_TO_QQ_TYPE.IMAGE:
        shareType = 5;
        break;
      case SHARE_TO_QQ_TYPE.APP:
        shareType = 6;
        break;
      default:
        shareType = 1;
    }
    params = {
      "shareType": shareType,
      "title": shareContent.title,
      "targetUrl": shareContent.targetUrl,
      "summary": shareContent.summary,
      "imageUrl": shareContent.imageUrl,
      // shareType == IMAGE,support imageLocalUrl only
      "imageLocalUrl": shareContent.imageLocalUrl,
      "appName": shareContent.appName,
      "audioUrl": shareContent.audioUrl,
      "qzoneFlag": shareContent.qzoneFlag.index,
      // app 信息?
      "ark": shareContent.ark
    };
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('shareToQQ', params);
    QQResult qqResult = new QQResult();
    qqResult.code = result["Code"];
    qqResult.message = result["Message"];
    return qqResult;
  }

  static Future<QQResult> shareToQzone(ShareQzoneContent shareContent) async {
    Map<String, dynamic> params;
    int shareType = 1;
    switch (shareContent.shareType) {
      case SHARE_TO_QZONE_TYPE.PUBLISH_MOOD:
        shareType = 3;
        break;
      case SHARE_TO_QZONE_TYPE.PUBLISH_VIDEO:
        shareType = 4;
        break;
      case SHARE_TO_QZONE_TYPE.IMAGE:
        shareType = 5;
        break;
      case SHARE_TO_QZONE_TYPE.APP:
        shareType = 6;
        break;
      default:
        shareType = 1;
    }
    params = {
      "shareType": shareType,
      "title": shareContent.title,
      "targetUrl": shareContent.targetUrl,
      "summary": shareContent.summary,
      "imageUrl": shareContent.imageUrl,
      "imageUrls": shareContent.imageUrls,
      // app 信息？
      "scene": shareContent.scene,
      "callback": shareContent.callback,
    };
    final Map<dynamic, dynamic> result =
        await _channel.invokeMethod('shareToQzone', params);
    QQResult qqResult = new QQResult();
    qqResult.code = result["Code"];
    qqResult.message = result["Message"];
    return qqResult;
  }
}
