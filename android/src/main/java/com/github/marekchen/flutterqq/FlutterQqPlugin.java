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

    public static Tencent mTencent;
    private Registrar registrar;

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
            case "registerQq":
                String mAppid = call.argument("appId");
                mTencent = Tencent.createInstance(mAppid, registrar.context());
                result.success(null);
                break;
            case "login":
                listener.setResult(result);
                mTencent.login(registrar.activity(), "all", listener);
                break;
            case "shareToQQ":
                listener.setResult(result);
                doShareToQQ(call, listener);
                break;
            case "shareToQzone":
                listener.setResult(result);
                doShareToQzone(call, listener);
                break;
        }
    }

    private void doShareToQQ(MethodCall call, final OneListener listener) {
        final Bundle params = new Bundle();
        int shareType = call.argument("shareType");
        Log.w("FlutterQqPlugin", "arguments:" + call.arguments);
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
        Log.w("chenpei", "params:" + params);
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
        Log.w("FlutterQqPlugin", "arguments:" + call.arguments);
        params.putString(QzoneShare.SHARE_TO_QQ_TITLE, (String) call.argument("title"));
        params.putString(QzoneShare.SHARE_TO_QQ_TARGET_URL, (String) call.argument("targetUrl"));
        params.putString(QzoneShare.SHARE_TO_QQ_SUMMARY, (String) call.argument("summary"));
        params.putStringArrayList(QQShare.SHARE_TO_QQ_IMAGE_URL, (ArrayList<String>) call.argument("imageUrls"));
        params.putInt(QzoneShare.SHARE_TO_QZONE_KEY_TYPE, shareType);
        params.putString(QzonePublish.PUBLISH_TO_QZONE_VIDEO_PATH, (String) call.argument("videoPath"));
        Bundle bundle2 = new Bundle();
        bundle2.putString(QzonePublish.HULIAN_EXTRA_SCENE, (String) call.argument("scene"));
        bundle2.putString(QzonePublish.HULIAN_CALL_BACK, (String) call.argument("hulian_call_back"));
        params.putBundle(QzonePublish.PUBLISH_TO_QZONE_EXTMAP, bundle2);
        Log.w("chenpei", "params:" + params);
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
            re.put("Code", 0);
            re.put("Message", response.toString());
            result.success(re);
        }

        @Override
        public void onError(UiError uiError) {
            Log.w("FlutterQqPlugin", "error:" + uiError.errorMessage);
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
