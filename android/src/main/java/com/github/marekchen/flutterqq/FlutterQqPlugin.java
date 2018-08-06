package com.github.marekchen.flutterqq;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import com.tencent.connect.common.Constants;
import com.tencent.connect.share.QQShare;
import com.tencent.connect.share.QzonePublish;
import com.tencent.connect.share.QzoneShare;
import com.tencent.tauth.IUiListener;
import com.tencent.tauth.Tencent;
import com.tencent.tauth.UiError;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterQqPlugin
 */
public class FlutterQqPlugin implements MethodCallHandler {

    private static Tencent mTencent;
    private Registrar registrar;
    private boolean isLogin;

    private FlutterQqPlugin(Registrar registrar) {
        this.registrar = registrar;
    }

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_qq");
        final FlutterQqPlugin instance = new FlutterQqPlugin(registrar);
        channel.setMethodCallHandler(instance);
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        OneListener listener = new OneListener();
        registrar.addActivityResultListener(listener);
        switch (call.method) {
            case "registerQQ":
                registerQQ(call, result);
                break;
            case "isQQInstalled":
                isQQInstalled(call, result);
                break;
            case "login":
                isLogin = true;
                listener.setResult(result);
                login(call, listener);
                break;
            case "shareToQQ":
                isLogin = false;
                listener.setResult(result);
                doShareToQQ(call, listener);
                break;
            case "shareToQzone":
                isLogin = false;
                listener.setResult(result);
                doShareToQzone(call, listener);
                break;
        }
    }

    private void registerQQ(MethodCall call, Result result) {
        String mAppid = call.argument("appId");
        mTencent = Tencent.createInstance(mAppid, registrar.context());
        result.success(true);
    }

    private void isQQInstalled(MethodCall call, Result result) {
        result.success(mTencent.isQQInstalled(registrar.activeContext()));
    }

    private void login(MethodCall call, final OneListener listener) {
        String scopes = (String) call.argument("scopes");
        if (mTencent.isSessionValid()) {
            mTencent.login(registrar.activity(), scopes == null ? "get_simple_userinfo" : scopes, listener);
        } else {
            Map<String, Object> re = new HashMap<>();
            re.put("Code", 1);
            re.put("Message", "session invalid");
            listener.result.success(re);
        }
    }

    private void doShareToQQ(MethodCall call, final OneListener listener) {
        final Bundle params = new Bundle();
        int shareType = call.argument("shareType");
        Log.i("FlutterQqPlugin", "arguments:" + call.arguments);
        if (shareType != QQShare.SHARE_TO_QQ_TYPE_IMAGE) {
            params.putString(QQShare.SHARE_TO_QQ_TITLE, (String) call.argument("title"));
            params.putString(QQShare.SHARE_TO_QQ_TARGET_URL, (String) call.argument("targetUrl"));
            params.putString(QQShare.SHARE_TO_QQ_SUMMARY, (String) call.argument("summary"));
        }
        if (shareType == QQShare.SHARE_TO_QQ_TYPE_IMAGE) {
            params.putString(QQShare.SHARE_TO_QQ_IMAGE_LOCAL_URL, (String) call.argument("imageLocalUrl"));
        } else {
            params.putString(QQShare.SHARE_TO_QQ_IMAGE_URL, (String) call.argument("imageUrl"));
        }
        params.putString(QQShare.SHARE_TO_QQ_APP_NAME, (String) call.argument("appName"));
        params.putInt(QQShare.SHARE_TO_QQ_KEY_TYPE, shareType);
        params.putInt(QQShare.SHARE_TO_QQ_EXT_INT, (Integer) call.argument("qzoneFlag"));
        if (shareType == QQShare.SHARE_TO_QQ_TYPE_AUDIO) {
            params.putString(QQShare.SHARE_TO_QQ_AUDIO_URL, (String) call.argument("audioUrl"));
        }
        params.putString(QQShare.SHARE_TO_QQ_ARK_INFO, (String) call.argument("ark"));
        Log.i("FlutterQqPlugin", "params:" + params);
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
                mTencent.shareToQQ(registrar.activity(), params, listener);
            }
        });
    }

    private void doShareToQzone(MethodCall call, final OneListener listener) {
        final Bundle params = new Bundle();
        int shareType = call.argument("shareType");
        Log.i("FlutterQqPlugin", "arguments:" + call.arguments);
        params.putInt(QzoneShare.SHARE_TO_QZONE_KEY_TYPE, shareType);
        params.putString(QzoneShare.SHARE_TO_QQ_TITLE, (String) call.argument("title"));
        params.putString(QzoneShare.SHARE_TO_QQ_SUMMARY, (String) call.argument("summary"));
        params.putString(QzoneShare.SHARE_TO_QQ_TARGET_URL, (String) call.argument("targetUrl"));
        params.putStringArrayList(QQShare.SHARE_TO_QQ_IMAGE_URL, (ArrayList<String>) call.argument("imageUrls"));
        params.putString(QzonePublish.PUBLISH_TO_QZONE_VIDEO_PATH, (String) call.argument("videoPath"));
        Bundle bundle2 = new Bundle();
        bundle2.putString(QzonePublish.HULIAN_EXTRA_SCENE, (String) call.argument("scene"));
        bundle2.putString(QzonePublish.HULIAN_CALL_BACK, (String) call.argument("hulian_call_back"));
        params.putBundle(QzonePublish.PUBLISH_TO_QZONE_EXTMAP, bundle2);
        Log.i("FlutterQqPlugin", "params:" + params);
        if (shareType == QzoneShare.SHARE_TO_QZONE_TYPE_IMAGE_TEXT) {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    mTencent.shareToQzone(registrar.activity(), params, listener);
                }
            });
        } else {
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    mTencent.publishToQzone(registrar.activity(), params, listener);
                }
            });
        }
    }

    private class OneListener implements IUiListener, PluginRegistry.ActivityResultListener {

        private Result result;

        void setResult(Result result) {
            this.result = result;
        }

        @Override
        public void onComplete(Object response) {
            Log.i("FlutterQqPlugin", response.toString());
            Map<String, Object> re = new HashMap<>();
            if (isLogin) {
                if (null == response) {
                    re.put("Code", 1);
                    re.put("Message", "response is empty");
                    result.success(re);
                    return;
                }
                JSONObject jsonResponse = (JSONObject) response;
                if (null != jsonResponse && jsonResponse.length() == 0) {
                    re.put("Code", 1);
                    re.put("Message", "response is empty");
                    result.success(re);
                    return;
                }
                Map<String, Object> resp = new HashMap<>();
                try {
                    resp.put("openid", jsonResponse.getString(Constants.PARAM_OPEN_ID));
                    resp.put("access_token", jsonResponse.getString(Constants.PARAM_ACCESS_TOKEN));
                    resp.put("expires_in", jsonResponse.getLong(Constants.PARAM_EXPIRES_IN));
                    resp.put("oauth_consumer_key", jsonResponse.getString(Constants.PARAM_CONSUMER_KEY));
                    re.put("Code", 0);
                    re.put("Message", "ok");
                    re.put("Response", resp);
                    result.success(re);
                    return;
                } catch (Exception e) {
                    re.put("Code", 1);
                    re.put("Message", e.getLocalizedMessage());
                    result.success(re);
                    return;
                }
            }
            re.put("Code", 0);
            re.put("Message", response.toString());
            result.success(re);
        }

        @Override
        public void onError(UiError uiError) {
            Log.w("FlutterQqPlugin", "errorCode:" + uiError.errorCode + ";errorMessage:" + uiError.errorMessage);
            Map<String, Object> re = new HashMap<>();
            re.put("Code", 1);
            re.put("Message", "errorCode:" + uiError.errorCode + ";errorMessage:" + uiError.errorMessage);
            result.success(re);
        }

        @Override
        public void onCancel() {
            Log.w("FlutterQqPlugin", "error:cancel");
            Map<String, Object> re = new HashMap<>();
            re.put("Code", 2);
            re.put("Message", "cancel");
            result.success(re);
        }

        @Override
        public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
            if (requestCode == Constants.REQUEST_LOGIN ||
                    requestCode == Constants.REQUEST_QQ_SHARE ||
                    requestCode == Constants.REQUEST_QZONE_SHARE ||
                    requestCode == Constants.REQUEST_APPBAR) {
                Tencent.onActivityResultData(requestCode, resultCode, data, this);
                return true;
            }
            return false;
        }
    }
}
