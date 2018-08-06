# flutter_qq

Flutter plugin for QQ.

## Getting Started
### android
1. Add the following to your project's AndroidManifest.xml and replace [QQ APPId] with your own QQ AppId
``` xml
<activity
    android:name="com.tencent.connect.common.AssistActivity"
    android:configChanges="orientation|keyboardHidden"
    android:screenOrientation="behind"
    android:theme="@android:style/Theme.Translucent.NoTitleBar" />
<activity
    android:name="com.tencent.tauth.AuthActivity"
    android:launchMode="singleTask"
    android:noHistory="true" >
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="[QQ APPId]" />
    </intent-filter>
</activity>
```

### iOS
1. Add the followings to your project's Info.plist
``` xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>tencent</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>tencent1107493622</string>
    </array>
  </dict>
</array>
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>mqq</string>
  <string>mqqapi</string>
  <string>mqqwpa</string>
  <string>mqqbrowser</string>
  <string>mttbrowser</string>
  <string>mqqOpensdkSSoLogin</string>
  <string>mqqopensdkapiV2</string>
  <string>mqqopensdkapiV3</string>
  <string>mqqopensdkapiV4</string>
  <string>wtloginmqq2</string>
  <string>mqzone</string>
  <string>mqzoneopensdk</string>
  <string>mqzoneopensdkapi</string>
  <string>mqzoneopensdkapi19</string>
  <string>mqzoneopensdkapiV2</string>
  <string>mqqapiwallet</string>
  <string>mqqopensdkfriend</string>
  <string>mqqopensdkdataline</string>
  <string>mqqgamebindinggroup</string>
  <string>mqqopensdkgrouptribeshare</string>
  <string>tencentapi.qq.reqContent</string>
  <string>tencentapi.qzone.reqContent</string>
</array>
<key>NSMicrophoneUsageDescription</key>
<string>microphoneUsageDescription</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>photoLibraryDesciption</string>
<key>NSCameraUsageDescription</key>
<string>cameraUsageDesciption</string>
<key>LSRequiresIPhoneOS</key>
<true/>
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

2. Add the followings to your project's AppDelegate.m
``` objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    NSString * urlStr = [url absoluteString];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"QQ" object:nil userInfo:@{@"url":urlStr}];
    return YES;
}
```

## Not Complete
1. SHARE_TO_QQ_TYPE.AUDIO
2. SHARE_TO_QZONE_TYPE.PUBLISH_VIDEO
3. SHARE_TO_QQ_TYPE.APP & SHARE_TO_QZONE_TYPE.APP
4. SHARE_TO_QZONE_TYPE.IMAGE_TEXT,android & ios don't have same action

## Api Documentation
### Data struct
1. QQResult

|field|type|description|
|-----|----|-----------|
|code|int|错误码 0:成功 1:发生错误 2:用户取消|
|message|String|错误详情|
|response|Map|只在login时返回|

response格式为:
``` json
{
  "openid":"xxxxx",
  "accessToken":"XXXXXXXXX",
  "expiresAt":"xxxxxxxxx",
}
```

2. QZONE_FLAG(enum)

|field|description|
|-----|-----------|
|DEFAULT|默认|
|AUTO_OPEN|在好友选择列表会自动打开分享到qzone的弹窗|
|ITEM_HIDE|在好友选择列表隐藏了qzone分享选项|

3. SHARE_TO_QQ_TYPE(enum)

|field|description|
|-----|-----------|
|DEFAULT|默认|
|AUDIO|音频|
|IMAGE|图片|
|APP|应用|

4. SHARE_TO_QZONE_TYPE(enum)

|field|description|
|-----|-----------|
|IMAGE_TEXT|默认|
|PUBLISH_MOOD|说说|
|PUBLISH_VIDEO|视频|
|IMAGE|图片|
|APP|应用|

5. ShareQQContent

|field|type|description|
|-----|----|-----------|
|shareType|SHARE_TO_QQ_TYPE|分享类型|
|title|String|title|
|targetUrl|String|targetUrl|
|summary|String|summary|
|imageUrl|String|imageUrl(shareType为IMAGE时，只支持imageLocalUrl)|
|imageLocalUrl|String|imageLocalUrl|
|appName|String|appName|
|audioUrl|String|audioUrl(只有shareType为AUDIO时支持)|
|qzoneFlag|QZONE_FLAG|qzone flag|

6. ShareQzoneContent

|field|type|description|
|-----|----|-----------|
|shareType|SHARE_TO_QZONE_TYPE|分享类型|
|title|String|title|
|targetUrl|String|targetUrl|
|summary|String|summary|
|imageUrls|List<String>|imageUrl|
|scene|String|scene|
|callback|String|callback|

### Method
1. registerQQ
``` dart
FlutterQq.registerQQ('YOUR_QQ_APPId');
```

2. isQQInstalled
``` dart
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
```

3. login
``` dart
Future<Null> _handleLogin() async {
  try {
    var qqResult = await FlutterQq.login();
    var output;
    if (qqResult.code == 0) {
      output = "登录成功" + qqResult.response.toString();
    } else if (qqResult.code == 1) {
      output = "登录失败" + qqResult.message;
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
```

4. shareToQQ
``` dart
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
```

5. shareToQzone
``` dart
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
```

## How To Contribute
### android
1. add your own flutter.sdk path to local.properties
```
flutter.sdk=YOUR_OWN_FLUTTER_SDK_PATH
```

2. PR