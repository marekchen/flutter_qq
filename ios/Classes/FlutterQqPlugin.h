#import <Flutter/Flutter.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>

#define SHARE_TO_QQ_TYPE_DEFAULT 1 // 默认（图片文字） news
#define SHARE_TO_QZONE_TYPE_IMAGE_TEXT 1 // 图片文字 news

#define SHARE_TO_QQ_TYPE_AUDIO 2 // 音频

#define PUBLISH_TO_QZONE_TYPE_PUBLISHMOOD 3 // 说说
#define PUBLISH_TO_QZONE_TYPE_PUBLISHVIDEO 4 // 视频

#define SHARE_TO_QQ_TYPE_IMAGE 5 // 图片（本地图片）
#define SHARE_TO_QZONE_TYPE_IMAGE 5

#define SHARE_TO_QQ_TYPE_APP 6 // App
#define SHARE_TO_QZONE_TYPE_APP 6

@interface FlutterQqPlugin : NSObject<FlutterPlugin>
@end
