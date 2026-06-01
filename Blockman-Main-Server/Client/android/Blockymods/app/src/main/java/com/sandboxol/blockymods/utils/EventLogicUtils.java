package com.sandboxol.blockymods.utils;

import android.content.Context;

import com.sandboxol.blockymods.config.EventConstant;
import com.sandboxol.blockymods.config.SharedConstant;
import com.sandboxol.common.utils.DateUtils;
import com.sandboxol.common.utils.SharedUtils;
import com.tendcloud.tenddata.TCAgent;

import java.util.Date;

/**
 * 统计第一天进入小游戏，第二天也进入小游戏的数量逻辑（次日留存）
 * Created by Bob on 2017/11/22.
 */
public class EventLogicUtils {

    private static Boolean isFirstDayEvent(Context context, String gameType) {
        return SharedUtils.getLong(context, SharedConstant.EVENT_FIRST_DAY + gameType) == 0;
    }

    private static Boolean isSecondDayEvent(Context context, String gameType) {
        String DAY_FORMAT = "yyyy-MM-dd";
        long first = SharedUtils.getLong(context, SharedConstant.EVENT_FIRST_DAY + gameType);
        long second = SharedUtils.getLong(context, SharedConstant.EVENT_SECOND_DAY + gameType);
        return second == 0 && DateUtils.date2TimeStamp(DateUtils.timeStamp2Date(new Date().getTime(), DAY_FORMAT), DAY_FORMAT) -
                        DateUtils.date2TimeStamp(DateUtils.timeStamp2Date(first, DAY_FORMAT), DAY_FORMAT) == 86400000L;
    }

    /**
     * 进入游戏统计
     */
    public static void enterGameLogic(Context context, String gameType) {
        if (isFirstDayEvent(context, gameType)) {
            SharedUtils.putLong(context, SharedConstant.EVENT_FIRST_DAY + gameType, new Date().getTime());
            TCAgent.onEvent(context, EventConstant.FIRST_GAMES_USER, gameType);
        } else if (!isFirstDayEvent(context, gameType) && isSecondDayEvent(context, gameType)) {
            SharedUtils.putLong(context, SharedConstant.EVENT_SECOND_DAY + gameType, new Date().getTime());
            TCAgent.onEvent(context, EventConstant.NEXT_GAMES_USER, gameType);
        }
    }

}
