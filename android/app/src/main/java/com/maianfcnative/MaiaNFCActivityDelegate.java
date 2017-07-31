package com.maianfcnative;

import android.os.Bundle;
import android.content.Intent;
import android.app.Activity;

import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Parcelable;
import android.util.Log;

import javax.annotation.Nullable;

import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.WritableMap;

public class MaiaNFCActivityDelegate extends ReactActivityDelegate {
    private Bundle initialProps = null;
    private final @Nullable Activity activity;

    public MaiaNFCActivityDelegate(Activity activity, String mainComponentName) {
        super(activity, mainComponentName);
        Log.i("ACTIVITY DELEGATE", "TESTING");
        this.activity = activity;
    }

    @Override
    protected Bundle getLaunchOptions() {
        return initialProps;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        initialProps = new Bundle();
        Intent intent = activity.getIntent();
        String action = intent.getAction();

        if (action != null && action.equals(NfcAdapter.ACTION_NDEF_DISCOVERED)) {
            WritableMap map = parseNFCIntent(intent);
            initialProps.putString("mime_type", map.getString("payload"));
            initialProps.putString("mime_type", map.getString("mime_type"));
        }

        super.onCreate(savedInstanceState);
    }

    @Override
    public boolean onNewIntent(Intent intent) {
        String action = intent.getAction();
        if (action != null && action.equals(NfcAdapter.ACTION_NDEF_DISCOVERED)) {
            Log.i("NEW INTENT", action);
            WritableMap map = parseNFCIntent(intent);
            getReactInstanceManager().getCurrentReactContext()
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("new_tag", map);

        }
        return super.onNewIntent(intent);
    }

    private WritableMap parseNFCIntent(Intent intent) {
        Parcelable[] rawMsgs = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
        WritableMap map = Arguments.createMap();

        for (int i = 0; i < rawMsgs.length; i++) {
            NdefMessage msg = (NdefMessage) rawMsgs[i];
            NdefRecord record = msg.getRecords()[0];
            byte[] payload = record.getPayload();
            String payload_string = new String(payload);

            map.putString("payload", payload_string);
            map.putString("mime_type", record.toMimeType());
        }

        return map;
    }

};


