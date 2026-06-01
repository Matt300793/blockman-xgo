package com.sandboxol.mapeditor.view.widget;

import android.app.Activity;
import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.sandboxol.common.utils.SizeUtil;
import com.sandboxol.mapeditor.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
public class MoreView extends PopupWindow implements AdapterView.OnItemClickListener {

    private Activity activity;
    private OnMoreItemClickListener onMoreItemClickListener;
    private List<MoreItem> items = new ArrayList<>();

    public MoreView(Activity activity) {
        this.activity = activity;
        initView();
    }

    private void initView() {
        LayoutInflater inflater = (LayoutInflater) activity.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = inflater.inflate(R.layout.view_more, null);
        this.setContentView(view);
        this.setWidth(LinearLayout.LayoutParams.MATCH_PARENT);
        this.setHeight(SizeUtil.getDeviceHeight(activity) - SizeUtil.getTopBarHeight(activity));
        this.setFocusable(true);
        this.setTouchable(true);
        this.setOutsideTouchable(true);
        initMoreListView(view.findViewById(R.id.lvMore));
        view.setOnClickListener(v -> dismiss());
    }


    @Override
    public void showAsDropDown(View anchor) {
        super.showAsDropDown(anchor, 0, activity.getResources().getDimensionPixelOffset(R.dimen.space4_5dp));
    }

    private void initMoreListView(ListView lvMore) {
        items.add(new MoreItem(R.mipmap.ic_export, R.string.my_map_export));
        items.add(new MoreItem(R.mipmap.ic_import, R.string.my_map_import));
        items.add(new MoreItem(R.mipmap.ic_editor, R.string.my_map_editor));
        items.add(new MoreItem(R.mipmap.ic_delete, R.string.my_map_delete));
        items.add(new MoreItem(R.mipmap.ic_backup, R.string.my_map_backup));
        MoreAdapter adapter = new MoreAdapter(activity, items);
        lvMore.setAdapter(adapter);
        lvMore.setOnItemClickListener(this);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        dismiss();
        if (onMoreItemClickListener != null) {
            onMoreItemClickListener.onClick(position);
        }
    }

    public MoreView setOnMoreItemClickListener(OnMoreItemClickListener onMoreItemClickListener) {
        this.onMoreItemClickListener = onMoreItemClickListener;
        return this;
    }

    public interface OnMoreItemClickListener {
        void onClick(int position);
    }

    private class MoreAdapter extends BaseAdapter {

        private LayoutInflater inflater;
        private List<MoreItem> items;

        private MoreAdapter(Context context, List<MoreItem> items) {
            this.items = items;
            this.inflater = LayoutInflater.from(context);
        }

        @Override
        public int getCount() {
            return items.size();
        }

        @Override
        public Object getItem(int position) {
            return items.get(position);
        }

        @Override
        public long getItemId(int position) {
            return position;
        }

        @NonNull
        @Override
        public View getView(int position, @Nullable View convertView, @NonNull ViewGroup parent) {
            ViewHolder holder;
            if (convertView == null) {
                holder = new ViewHolder();
                convertView = inflater.inflate(R.layout.item_more, null);
                holder.ivIcon = convertView.findViewById(R.id.ivIcon);
                holder.tvText = convertView.findViewById(R.id.tvText);
                convertView.setTag(holder);
            } else {
                holder = (ViewHolder) convertView.getTag();
            }
            MoreItem item = (MoreItem) getItem(position);
            if (item != null) {
                holder.ivIcon.setImageResource(item.icon);
                holder.tvText.setText(item.title);
            }
            return convertView;
        }

        private class ViewHolder {
            private ImageView ivIcon;
            private TextView tvText;
        }

    }

    private class MoreItem {

        private int icon;
        private int title;

        private MoreItem(int icon, int title) {
            this.icon = icon;
            this.title = title;
        }
    }
}
