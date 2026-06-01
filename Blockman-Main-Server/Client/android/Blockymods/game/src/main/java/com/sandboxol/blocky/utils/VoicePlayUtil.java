package com.sandboxol.blocky.utils;

import android.content.Context;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.SoundPool;
import android.os.Build;
import android.util.SparseIntArray;

import com.sandboxol.game.R;
import com.sandboxol.common.base.app.BaseApplication;

public class VoicePlayUtil {

    private static VoicePlayUtil mMe;
    private SoundPool mSoundPool;
    private SparseIntArray mMap;

    public static VoicePlayUtil getMe() {
        return mMe;
    }

    public static VoicePlayUtil init() {
        if (mMe == null) {
            mMe = new VoicePlayUtil();
        }

        return mMe;
    }

    private VoicePlayUtil() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            mSoundPool = new SoundPool.Builder().setMaxStreams(2).setAudioAttributes(new AudioAttributes.Builder().setLegacyStreamType(AudioManager.STREAM_MUSIC).build()).build();
        } else {
            mSoundPool = new SoundPool(2, AudioManager.STREAM_MUSIC, 0);
        }
        mMap = new SparseIntArray() {
            {
                put(1, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_1_death_thunder16, 1));
                put(2, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_2_death_result_level_up, 1));
                put(3, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_3_death_drop_bow, 1));
                put(4, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_4_pick_up_step1, 1));
                put(5, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_5_open_diamond_anvil_land, 1));
                put(6, mSoundPool.load(BaseApplication.getApp(), R.raw.voice_6_win_remedy, 1));
            }
        };
    }

    public int voicePay(int key) {
        if (key == 7) {
            return 0;
        } else {
            AudioManager am = (AudioManager) BaseApplication.getApp().getSystemService(Context.AUDIO_SERVICE);
            float audioMaxVolume = am.getStreamMaxVolume(AudioManager.STREAM_MUSIC);
            float audioCurrentVolume = am.getStreamVolume(AudioManager.STREAM_MUSIC);
            float volumeRatio = audioCurrentVolume / audioMaxVolume;
            if (mMap.get(key) == 0)
                return 0;
            return mSoundPool.play(mMap.get(key), volumeRatio, volumeRatio, 1, 0, 1);
        }

    }


    public void voiceStop() {
        try {
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
