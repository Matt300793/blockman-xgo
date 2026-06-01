package com.sandboxol.blockymods.view.fragment.category;

import android.content.Context;
import android.databinding.ObservableField;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.sandboxol.blockymods.R;
import com.sandboxol.blockymods.config.IntConstant;
import com.sandboxol.blockymods.config.StringConstant;
import com.sandboxol.blockymods.view.widget.CategoryPopupWindow;
import com.sandboxol.common.base.viewmodel.ViewModel;
import com.sandboxol.common.binding.adapter.RadioGroupBindingAdapters;
import com.sandboxol.common.command.ReplyCommand;
import com.sandboxol.common.utils.ToastUtils;

import java.util.ArrayList;
import java.util.List;

import rx.functions.Action0;

/**
 * Created by Bob on 2017/11/3.
 */
public class CategoryViewModel extends ViewModel {

    private Context context;
    private CategoryPopupWindow window;
    private LinearLayout llCategory;
    private long gameType = IntConstant.GAME_TYPE_ALL;
    private String gameOrderType = StringConstant.GAME_ORDER_TYPE_ONLINE_TIME;

    public CategoryGameModel categoryGameModel;
    public CategoryListLayout categoryListLayout = new CategoryListLayout();
    public ObservableField<String> gameOrderText = new ObservableField<>();
    public ObservableField<Boolean> gameOrderCheck = new ObservableField<>(false);

    public ReplyCommand<RadioGroupBindingAdapters.CheckedDataWrapper> onCheckChangeCommand = new ReplyCommand<>(checkedDataWrapper -> check(checkedDataWrapper.getCheckedId()));
    public ReplyCommand onClickCategoryCommand = new ReplyCommand(this::showWindow);

    public CategoryViewModel(Context context) {
        this.context = context;
        categoryGameModel = new CategoryGameModel(context, R.string.category_no_data, gameOrderType, gameType);
        gameOrderText.set(context.getString(R.string.category_online_time));
    }

    private void check(int checkId) {
        switch (checkId) {
            case R.id.rbAll:
                gameType = IntConstant.GAME_TYPE_ALL;
                break;
            case R.id.rbPvp:
                gameType = IntConstant.GAME_TYPE_PVP;
                break;
            case R.id.rbManage:
                gameType = IntConstant.GAME_TYPE_BUSINESS;
                break;
            case R.id.rbAdventure:
                gameType = IntConstant.GAME_TYPE_ADVENTURE;
                break;
            case R.id.rbGun:
                gameType = IntConstant.GAME_TYPE_SHOOTOUT;
                break;
            case 0:
                gameOrderType = StringConstant.GAME_ORDER_TYPE_APPRECIATION;
                gameOrderText.set(context.getString(R.string.category_appreciation));
                break;
            case 1:
                gameOrderType = StringConstant.GAME_ORDER_TYPE_POPULATION;
                gameOrderText.set(context.getString(R.string.category_population));
                break;
            case 2:
                gameOrderType = StringConstant.GAME_ORDER_TYPE_ONLINE_TIME;
                gameOrderText.set(context.getString(R.string.category_online_time));
                break;
        }
        categoryGameModel.refreshGames(gameOrderType, gameType);
    }

    void setLlCategory(LinearLayout llCategory) {
        this.llCategory = llCategory;
    }

    private void showWindow() {
        if (window == null) {
            List<String> list = new ArrayList<>();
            list.add(context.getString(R.string.category_appreciation));
            list.add(context.getString(R.string.category_population));
            list.add(context.getString(R.string.category_online_time));
            window = new CategoryPopupWindow(context, list);
        }
        if (window.isShowing()) {
            window.dismiss();
        } else {
            window.showLocation(llCategory);
            gameOrderCheck.set(true);
            window.setOnMoreItemClickListener(new CategoryPopupWindow.OnMoreItemClickListener() {
                @Override
                public void onClick(int position, long id) {
                    check(position);
                }

                @Override
                public void onCheck() {
                    gameOrderCheck.set(false);
                }
            });
        }
    }
}
