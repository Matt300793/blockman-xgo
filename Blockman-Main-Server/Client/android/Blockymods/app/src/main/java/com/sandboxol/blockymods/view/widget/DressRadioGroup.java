package com.sandboxol.blockymods.view.widget;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RadioGroup;

import com.sandboxol.blockymods.R;

/**
 * Created by Bob on 2017/11/27.
 */
public class DressRadioGroup extends FrameLayout {

    private OnTabChangeListener listener;
    private RadioGroup rgDress;
    private ImageView ivCurrent;

    public DressRadioGroup(Context context) {
        this(context, null);
    }


    public DressRadioGroup(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    private void init(Context context) {
        View.inflate(context, R.layout.view_dress_radio_group, this);
        rgDress = findViewById(R.id.rgDress);
        ivCurrent = findViewById(R.id.ivCurrent);
        rgDress.setOnCheckedChangeListener((group, checkedId) -> {
            if (checkedId == -1) {
                return;
            }
            ivCurrent.setEnabled(true);
            if (listener != null) {
                switch (checkedId) {
                    case R.id.rbCloth:
                        listener.onTabSelected(Tab.CLOTH);
                        break;
                    case R.id.rbHair:
                        listener.onTabSelected(Tab.HAIR);
                        break;
                    case R.id.rbOrnaments:
                        listener.onTabSelected(Tab.ORNAMENTS);
                        break;
                    case R.id.rbEmoticon:
                        listener.onTabSelected(Tab.EMOTICON);
                        break;
                    case R.id.rbAction:
                        listener.onTabSelected(Tab.ACTION);
                        break;
                    case R.id.rbHeight:
                        listener.onTabSelected(Tab.HEIGHT);
                        break;
                    case R.id.rbColor:
                        listener.onTabSelected(Tab.COLOR);
                        break;
                    default:
                        break;
                }
            }
        });
        ivCurrent.setOnClickListener(v -> selectCurrentTab());
    }

    private void selectCurrentTab() {
        rgDress.clearCheck();
        ivCurrent.setEnabled(false);
        if (listener != null) {
            listener.onTabSelected(Tab.CURRENT);
        }
    }

    public void selectTab(Tab tab) {
        switch (tab) {
            case CURRENT:
                selectCurrentTab();
                break;
            case CLOTH:
                rgDress.check(R.id.rbCloth);
                break;
            case HAIR:
                rgDress.check(R.id.rbHair);
                break;
            case ORNAMENTS:
                rgDress.check(R.id.rbOrnaments);
                break;
            case EMOTICON:
                rgDress.check(R.id.rbEmoticon);
                break;
            case ACTION:
                rgDress.check(R.id.rbAction);
                break;
            case HEIGHT:
                rgDress.check(R.id.rbHeight);
                break;
            case COLOR:
                rgDress.check(R.id.rbColor);
                break;
        }
    }

    public void setTabChangeListener(OnTabChangeListener listener) {
        this.listener = listener;
        selectCurrentTab();
    }

    public enum Tab {
        CURRENT(0), CLOTH(1), HAIR(2), ORNAMENTS(3), EMOTICON(4), ACTION(5), HEIGHT(6), COLOR(7);
        public int position;

        Tab(int position) {
            this.position = position;
        }

        public static Tab getTabByPosition(int position) {
            switch (position) {
                case 0:
                    return CURRENT;
                case 1:
                    return CLOTH;
                case 2:
                    return HAIR;
                case 3:
                    return ORNAMENTS;
                case 4:
                    return EMOTICON;
                case 5:
                    return ACTION;
                case 6:
                    return HEIGHT;
                case 7:
                    return COLOR;
                default:
                    return CURRENT;
            }
        }
    }

    public interface OnTabChangeListener {
        void onTabSelected(Tab tab);
    }
}
