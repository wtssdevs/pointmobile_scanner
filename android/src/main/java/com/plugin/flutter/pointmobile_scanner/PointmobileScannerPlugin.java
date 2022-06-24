package com.plugin.flutter.pointmobile_scanner;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import device.common.DecodeResult;
import device.common.DecodeStateCallback;
import device.common.ScanConst;
import device.sdk.ScanManager;

import java.util.ArrayList;

/** PointmobileScannerPlugin */
public class PointmobileScannerPlugin implements FlutterPlugin, MethodCallHandler {

  private static final String TAG = "ScannerFlutterPlugin";

  static final String _ON_DECODE = "onDecode";
  static final String _ON_ERROR = "onError";

  protected Context mContext;
  private static MethodChannel mChannel = null;
  private static ScanManager mScanner = null;
  private static DecodeResult mDecodeResult = null;
  private int mBackupResultType = ScanConst.ResultType.DCD_RESULT_COPYPASTE;

  private static ScanResultReceiver mScanResultReceiver = null;
  public static class ScanResultReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
      Log.d(TAG, "[onReceive]");
      if (mScanner != null) {
        try {
          if (ScanConst.INTENT_USERMSG.equals(intent.getAction())) {
            Log.d(TAG, "[onReceive] INTENT_USERMSG");
            mScanner.aDecodeGetResult(mDecodeResult.recycle());
            _onDecode(mDecodeResult);
          } else if (ScanConst.INTENT_EVENT.equals(intent.getAction())) {
            //Log.d(TAG, "[onReceive] INTENT_EVENT");
            boolean result = intent.getBooleanExtra(ScanConst.EXTRA_EVENT_DECODE_RESULT, false);
            int decodeBytesLength = intent.getIntExtra(ScanConst.EXTRA_EVENT_DECODE_LENGTH, 0);
            byte[] decodeBytesValue = intent.getByteArrayExtra(ScanConst.EXTRA_EVENT_DECODE_VALUE);
            String decodeValue = new String(decodeBytesValue, 0, decodeBytesLength);
            int decodeLength = decodeValue.length();
            String symbolName = intent.getStringExtra(ScanConst.EXTRA_EVENT_SYMBOL_NAME);
            byte symbolId = intent.getByteExtra(ScanConst.EXTRA_EVENT_SYMBOL_ID, (byte) 0);
            int symbolType = intent.getIntExtra(ScanConst.EXTRA_EVENT_SYMBOL_TYPE, 0);
            byte letter = intent.getByteExtra(ScanConst.EXTRA_EVENT_DECODE_LETTER, (byte) 0);
            byte modifier = intent.getByteExtra(ScanConst.EXTRA_EVENT_DECODE_MODIFIER, (byte) 0);
            int decodingTime = intent.getIntExtra(ScanConst.EXTRA_EVENT_DECODE_TIME, 0);
            Log.d(TAG, "1. result: " + result);
            Log.d(TAG, "2. bytes length: " + decodeBytesLength);
            Log.d(TAG, "3. bytes value: " + decodeBytesValue);
            Log.d(TAG, "4. decoding length: " + decodeLength);
            Log.d(TAG, "5. decoding value: " + decodeValue);
            Log.d(TAG, "6. symbol name: " + symbolName);
            Log.d(TAG, "7. symbol id: " + symbolId);
            Log.d(TAG, "8. symbol type: " + symbolType);
            Log.d(TAG, "9. decoding letter: " + letter);
            Log.d(TAG, "10.decoding modifier: " + modifier);
            Log.d(TAG, "11.decoding time: " + decodingTime);
            _onDecode(mDecodeResult);
          }
        } catch (Exception e) {
          e.printStackTrace();
        }
      }
    }
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(TAG, "[onAttachedToEngine]");
    mContext = flutterPluginBinding.getApplicationContext();
    mChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "pointmobile_scanner");
    mChannel.setMethodCallHandler(this);
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    Log.d(TAG, "[onDetachedFromEngine]");
    mChannel.setMethodCallHandler(null);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("initScanner")) {
      Boolean initOk = _initScanner();
      result.success(initOk);
    } else if (call.method.equals("enableScanner")) {
      _enableScanner();
      result.success(true);
    } else if (call.method.equals("disableScanner")) {
      _disableScanner();
      result.success(true);
    } else if (call.method.equals("enableBeep")) {
      _enableBeep();
      result.success(true);
    } else if (call.method.equals("disableBeep")) {
      _disableBeep();
      result.success(true);
    } else if (call.method.equals("enableSymbology")) {
      int nSymId = Integer.parseInt(call.arguments.toString());
      _enableSymbology(nSymId);
      result.success(true);
    } else if (call.method.equals("disableSymbology")) {
      int nSymId = Integer.parseInt(call.arguments.toString());
      _disableSymbology(nSymId);
      result.success(true);
    } else if (call.method.equals("triggerOn")) {
      _triggerOn();
      result.success(true);
    } else if (call.method.equals("triggerOff")) {
      result.success(true);
    } else {
      result.notImplemented();
    }
  }

  private Boolean _initScanner() {
    Log.d(TAG, "[_initScanner]");
    try {
      if (mScanner == null) {
        mScanner = new ScanManager();
        Log.d(TAG, "[_initScanner] new ScanManager()");

        mScanner.aDecodeSetResultType(ScanConst.ResultType.DCD_RESULT_USERMSG);
        Log.d(TAG, "[_initScanner] SetResultType(USERMSG)");

        mScanResultReceiver = new ScanResultReceiver();
        IntentFilter filter = new IntentFilter();
        filter.addAction(ScanConst.INTENT_USERMSG);
        filter.addAction(ScanConst.INTENT_EVENT);
        mContext.registerReceiver(mScanResultReceiver, filter);
        Log.d(TAG, "[_initScanner] ScanResultReceiver is registered.");

        mDecodeResult = new DecodeResult();
      }
      return true;
    }
    catch (Throwable e) {
      Log.d(TAG, "[_initScanner] Failed to initialise Scanner");
      return false;
    }
  }

  private void _enableScanner() {
    if (mScanner != null) {
      Log.d(TAG, "[_enableScanner]");
      mScanner.aDecodeSetDecodeEnable(1);
    }
  }

  private void _disableScanner() {
    if (mScanner != null) {
      Log.d(TAG, "[_disableScanner]");
      mScanner.aDecodeSetDecodeEnable(0);
    }
  }

  private void _enableBeep() {
    if (mScanner != null) {
      Log.d(TAG, "[_enableBeep]");
      mScanner.aDecodeSetBeepEnable(1);
    }
  }

  private void _disableBeep() {
    if (mScanner != null) {
      Log.d(TAG, "[_disableBeep]");
      mScanner.aDecodeSetBeepEnable(0);
    }
  }

  private void _enableSymbology(int nSymId) {
    if (mScanner != null) {
      Log.d(TAG, "[_enableSymbology] nSymId=" + nSymId);
      mScanner.aDecodeSymSetEnable(nSymId, 1);
    }
  }

  private void _disableSymbology(int nSymId) {
    if (mScanner != null) {
      Log.d(TAG, "[_disableSymbology] nSymId=" + nSymId);
      mScanner.aDecodeSymSetEnable(nSymId, 0);
    }
  }

  private void _triggerOn() {
    if (mScanner != null) {
      Log.d(TAG, "[_triggerOn]");
      mScanner.aDecodeSetTriggerOn(1);
    }
  }

  private void _triggerOff() {
    if (mScanner != null) {
      Log.d(TAG, "[_triggerOff]");
      mScanner.aDecodeSetTriggerOn(0);
    }
  }

  private static void _onDecode(DecodeResult decodeResult) {
    ArrayList<String> alDecodeResult = new ArrayList<>();
    alDecodeResult.add(decodeResult.symName);
    alDecodeResult.add(decodeResult.toString());

    Log.d(TAG, "[_onDecode] " + alDecodeResult.toString());
    mChannel.invokeMethod(_ON_DECODE, alDecodeResult);
  }

  private void _onError(Exception error) {
    mChannel.invokeMethod(_ON_ERROR, error.getMessage());
  }
}
