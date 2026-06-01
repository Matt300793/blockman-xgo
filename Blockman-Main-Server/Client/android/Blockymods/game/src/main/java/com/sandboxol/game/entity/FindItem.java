package com.sandboxol.game.entity;

import java.util.List;

/**
 * Created by luoweiyi on 16/2/26.
 */
public class FindItem {
    private List<String> gameids;

    public FindItem(List<String> gameids) {
        this.gameids = gameids;
    }

    public void setGameids(List<String> gameids) {
        this.gameids = gameids;
    }
}
