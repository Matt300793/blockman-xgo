package com.sandboxol.blockymods.utils;

import java.util.List;

/**
 * Created by Bob on 2017/11/6.
 */
public class ViewModelUtils {

    /**
     * 游戏类型拼接
     * eg. PVP|冒险|休闲
     *
     * @param gameTypes
     * @return
     */
    public static String gameTypeManage(List<String> gameTypes) {
        String result = "";
        if (gameTypes != null)
            for (String type : gameTypes) {
                if (result.equals(""))
                    result = type;
                else
                    result = result + "|" + type;
            }
        return result;
    }
}
