package com.maianfcnative;

import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.app.Activity;

import android.nfc.NdefMessage;
import android.nfc.NdefRecord;
import android.nfc.NfcAdapter;
import android.os.Parcelable;
import android.util.Log;

import javax.annotation.Nullable;

import com.facebook.react.ReactActivityDelegate;

public class MaiaNFCActivityDelegate extends ReactActivityDelegate {
    private Bundle mInitialProps = null;
    private final @Nullable Activity activity;

    public MaiaNFCActivityDelegate(Activity activity, String mainComponentName) {
        super(activity, mainComponentName);
        Log.i("ACTIVITY DELEGATE", "TESTING");
        this.activity = activity;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        Log.i("ACTIVITY DELEGATE", "onCreate");
        mInitialProps = new Bundle();
        Intent intent = activity.getIntent();
        String action = intent.getAction();

        if (action != null && action.equals(NfcAdapter.ACTION_NDEF_DISCOVERED)) {
            Log.i("ACTIVITY DELEGATE", action);
            Parcelable[] rawMsgs = intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);

            for (int i = 0; i < rawMsgs.length; i++) {
                NdefMessage msg = (NdefMessage) rawMsgs[i];
                NdefRecord record = msg.getRecords()[0];
                byte[] payload = record.getPayload();
                String payload_string = new String(payload);

                mInitialProps.putString("payload", payload_string);
                mInitialProps.putString("mime_type", record.toMimeType());
            }
        }

        Log.i("ACTIVITY DELEGATE", "end of onCreate");
        super.onCreate(savedInstanceState);
    }

    @Override
    protected Bundle getLaunchOptions() {
        return mInitialProps;
    }
};


