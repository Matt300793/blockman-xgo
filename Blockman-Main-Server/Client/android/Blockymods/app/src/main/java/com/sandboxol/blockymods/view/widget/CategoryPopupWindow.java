package com.sandboxol.blockymods.view.widget;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.PopupWindow;

import com.sandboxol.blockymods.R;

import java.util.List;

/**
 * Created by Bob on 2017/11/8.
 */
public class CategoryPopupWindow extends PopupWindow implements AdapterView.OnItemClickListener {

    private Context context;
    private List<String> listItemText;
    private OnMoreItemClickListener onMoreItemClickListener;

    public CategoryPopupWindow(Context context, List<String> listItemText) {
        super(context);
        this.context = context;
        this.listItemText = listItemText;
        initView();
    }

    private void initView() {
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        View view = inflater.inflate(R.layout.view_category_window, null);
        this.setContentView(view);
        this.setWidth(LinearLayout.LayoutParams.MATCH_PARENT);
        this.setHeight(LinearLayout.LayoutParams.WRAP_CONTENT);
        this.setFocusable(true);
        this.setTouchable(true);
        this.setOutsideTouchable(true);
        ColorDrawable dw = new ColorDrawable(0x66000000);
        this.setBackgroundDrawable(dw);
        ListView lvCategory = view.findViewById(R.id.lvCategory);
        ArrayAdapter<String> adapter = new ArrayAdapter<>(context, R.layout.list_category_item, listItemText);
        lvCategory.setAdapter(adapter);
        lvCategory.setOnItemClickListener(this);
        this.setOnDismissListener(() -> onMoreItemClickListener.onCheck());
    }

    public void showLocation(View view) {
        showAsDropDown(view);
    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        dismiss();
        if (onMoreItemClickListener != null)
            onMoreItemClickListener.onClick(position, id);
    }

    public void setOnMoreItemClickListener(OnMoreItemClickListener onMoreItemClickListener) {
        this.onMoreItemClickListener = onMoreItemClickListener;
    }

    public interface OnMoreItemClickListener {
        void onClick(int position, long id);
        void onCheck();
    }
}
