#import "FlutterQqPlugin.h"

@interface FlutterQqPlugin()<QQApiInterfaceDelegate, TencentSessionDelegate> {
    TencentOAuth* _oauth;
    FlutterResult result;
}
@end

@implementation FlutterQqPlugin
- (instancetype)init
{
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOpenURL:)
                                                 name:@"QQ"
                                               object:nil];
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_qq"
            binaryMessenger:[registrar messenger]];
  FlutterQqPlugin* instance = [[FlutterQqPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)flutterResult {
    result=flutterResult;
    if ([@"registerQQ" isEqualToString:call.method]) {
        NSString *appId = call.arguments[@"appId"];
        _oauth = [[TencentOAuth alloc] initWithAppId:appId andDelegate:self];
    } else if([@"isQQInstalled" isEqualToString:call.method]){
        if([QQApiInterface isQQInstalled]){
            result(@(YES));
        }else{
            result(@(NO));
        }
    } else if([@"login" isEqualToString:call.method]){
        NSArray *scopeArray = nil;
        NSString *scopes = call.arguments[@"scopes"];
        if(scopes && scopes.length){
            scopeArray = [scopes componentsSeparatedByString:@","];
        }
        if (scopeArray == nil) {
            scopeArray = @[@"get_user_info", @"get_simple_userinfo"];
        }
        [_oauth authorize:scopeArray];
    } else if([@"shareToQQ" isEqualToString:call.method]){
        [self shareToQQ:call result:result];
    } else if([@"shareToQzone" isEqualToString:call.method]){
        [self shareToQzone:call result:result];
    }
}

- (void)shareToQQ:(FlutterMethodCall*)call result:(FlutterResult)flutterResult{
    int shareType = [call.arguments[@"shareType"] intValue];
    NSString *title = call.arguments[@"title"];
    NSString *description = call.arguments[@"summary"];
    NSString *imageUrl = call.arguments[@"imageUrl"];
    NSString *imageLocalUrl = call.arguments[@"imageLocalUrl"];
    NSString *webpageUrl = call.arguments[@"targetUrl"];
    NSString *audioUrl = call.arguments[@"audioUrl"];
    QQApiObject *message = nil;
    if(imageUrl.length) {
    }
    
    if(shareType == SHARE_TO_QQ_TYPE_DEFAULT){
        // news|Image
        message = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageURL:[NSURL URLWithString:imageUrl]];
    }
    else if(shareType == SHARE_TO_QQ_TYPE_IMAGE){
        // localImage
        if(imageLocalUrl.length) {
        }
        NSData *imageData = nil;//UIImageJPEGRepresentation(imageUrl, 1);
        message = [QQApiImageObject objectWithData:imageData previewImageData:imageData title:title description:description];
    }
    else if (shareType == SHARE_TO_QQ_TYPE_AUDIO){
        // audio
        QQApiAudioObject *audioObj = [QQApiAudioObject objectWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageURL:[NSURL URLWithString:imageUrl]];
        if(audioUrl) {
            [audioObj setFlashURL:[NSURL URLWithString:audioUrl]];
        }
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:message];
    [QQApiInterface sendReq:req];
}

- (void)shareToQzone:(FlutterMethodCall*)call result:(FlutterResult)flutterResult{
    int shareType = [call.arguments[@"shareType"] intValue];
    NSString *title = call.arguments[@"title"];
    NSString *description = call.arguments[@"summary"];
    NSString *imageUrl = call.arguments[@"imageUrl"];
    NSString *imageLocalUrl = call.arguments[@"imageLocalUrl"];
    NSString *webpageUrl = call.arguments[@"targetUrl"];
    QQApiObject *message = nil;
    
    if(shareType == SHARE_TO_QQ_TYPE_DEFAULT){
        // news|Image
        message = [QQApiNewsObject objectWithURL:[NSURL URLWithString:webpageUrl] title:title description:description previewImageURL:[NSURL URLWithString:imageUrl]];
    }
    else if(shareType == SHARE_TO_QQ_TYPE_IMAGE){
        // localImage
        if(imageLocalUrl.length) {
        }
        NSData *imageData = nil;//UIImageJPEGRepresentation(imageUrl, 1);
        message = [QQApiImageObject objectWithData:imageData previewImageData:imageData title:title description:description];
    }
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:message];
    [QQApiInterface SendReqToQZone:req];
}

- (BOOL)handleOpenURL:(NSNotification *)aNotification
{
    NSString * aURLString =  [aNotification userInfo][@"url"];
    NSURL * url = [NSURL URLWithString:aURLString];
    [QQApiInterface handleOpenURL:url delegate:self];
    if (YES == [TencentOAuth CanHandleOpenURL:url])
    {
        return [TencentOAuth HandleOpenURL:url];
    }
    return YES;
}

#pragma mark - QQApiInterfaceDelegate
- (void)onReq:(QQBaseReq *)req
{
    
}

- (void) onResp:(QQBaseResp *)resp
{
    if([resp isKindOfClass:[SendMessageToQQResp class]])
    {
        NSMutableDictionary *body = @{@"type":@"QQShareResponse"}.mutableCopy;
        SendMessageToQQResp* sendReq = (SendMessageToQQResp*)resp;
        if(sendReq.errorDescription) {
            body[@"Code"] = @(1);
        } else {
            body[@"Code"] = @(0);
        }
        body[@"Message"] = resp.result;
        result(body);
    }
}
- (void) isOnlineResponse:(NSDictionary *)response
{
    
}

#pragma mark - oauth delegate
- (void)tencentDidLogin
{
    NSMutableDictionary *body = @{@"type":@"QQAuthorizeResponse"}.mutableCopy;
    body[@"Code"] = @(0);
    body[@"Message"] = @"Ok";
    NSMutableDictionary *response = @{@"openid":_oauth.openId}.mutableCopy;
    body[@"openid"] = _oauth.openId;
    body[@"access_token"] = _oauth.accessToken;
    body[@"expires_in"] = @([_oauth.expirationDate timeIntervalSince1970]*1000);
    body[@"oauth_consumer_key"] =_oauth.appId;
    body[@"Response"] = response;
    result(body);
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    NSMutableDictionary *body = @{@"type":@"QQAuthorizeResponse"}.mutableCopy;
    if (cancelled) {
        body[@"Code"] = @(2);
        body[@"Message"] = @"login canceled";
    }
    else {
        body[@"Code"] = @(1);
        body[@"Message"] = @"login failed";
    }
}

- (void)tencentDidNotNetWork
{
}

@end
