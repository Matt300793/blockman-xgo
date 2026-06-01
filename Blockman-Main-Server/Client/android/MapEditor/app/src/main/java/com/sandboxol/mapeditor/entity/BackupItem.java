package com.sandboxol.mapeditor.entity;

import com.sandboxol.mapeditor.entity.dao.McMap;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
public class BackupItem {

    public McMap map;
    public long lately;
    public int num;

    public BackupItem(McMap map, long lately, int num) {
        this.map = map;
        this.lately = lately;
        this.num = num;
    }
}
