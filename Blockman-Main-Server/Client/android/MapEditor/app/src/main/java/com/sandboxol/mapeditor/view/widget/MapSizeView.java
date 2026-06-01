package com.sandboxol.mapeditor.view.widget;

import android.content.Context;
import android.support.annotation.AttrRes;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import com.sandboxol.mapeditor.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MapSizeView extends FrameLayout {

    private TextView tvMapSize;
    private SeekBar sbMapSize;
    private OnSizeChangeListener listener;

    private List<MapSize> sizes = new ArrayList<>();

    public MapSizeView(@NonNull Context context) {
        this(context, null);
    }

    public MapSizeView(@NonNull Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public MapSizeView(@NonNull Context context, @Nullable AttributeSet attrs, @AttrRes int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        View.inflate(getContext(), R.layout.view_map_size, this);
        tvMapSize = findViewById(R.id.tvMapSize);
        sbMapSize = findViewById(R.id.sbMapSize);
        sbMapSize.setOnSeekBarChangeListener(new SeekBar.OnSeekBarChangeListener() {
            @Override
            public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
                MapSize size = calculateProgress(progress);
                seekBar.setProgress(size.progress);
                tvMapSize.setText(size.text);
                if (listener != null) {
                    listener.onSizeChange(size);
                }
            }

            @Override
            public void onStartTrackingTouch(SeekBar seekBar) {

            }

            @Override
            public void onStopTrackingTouch(SeekBar seekBar) {

            }
        });
        initMapSizes();
    }

    private MapSize calculateProgress(int progress) {
        for (int i = 0; i < sizes.size(); i++) {
            MapSize cur = sizes.get(i);
            if (i < sizes.size() - 1) {
                if (progress < cur.progress)
                    return cur;
                MapSize next = sizes.get(i + 1);
                if (progress < cur.progress / 2 + next.progress / 2)
                    return cur;
                if (progress <= next.progress)
                    return next;
            } else {
                return cur;
            }
        }
        return sizes.get(2);
    }

    private void initMapSizes() {
        sizes.add(new MapSize(64, 2, "64*64"));
        sizes.add(new MapSize(128, 20, "128*128"));
        sizes.add(new MapSize(256, 50, "256*256"));
        sizes.add(new MapSize(512, 88, "512*512"));
        sizes.add(new MapSize(-1, 100, getContext().getResources().getString(R.string.new_map_infinite)));
        sbMapSize.setProgress(sizes.get(2).progress);
    }

    public void setOnSizeChangeListener(OnSizeChangeListener listener) {
        this.listener = listener;
    }

    public interface OnSizeChangeListener {
        void onSizeChange(MapSize size);
    }

    public class MapSize {

        private int size, progress;
        private String text;

        private MapSize(int size, int progress, String text) {
            this.size = size;
            this.progress = progress;
            this.text = text;
        }

        public int getSize() {
            return size;
        }

    }


}
