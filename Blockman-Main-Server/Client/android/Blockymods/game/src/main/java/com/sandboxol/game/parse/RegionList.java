package com.sandboxol.game.parse;

import com.sandboxol.game.entity.Region;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Mr.Luo on 16/2/27.
 */
public class RegionList {

    private List<Region> regionList;

    public List<Region> getRegionList() {
        return regionList == null ? new ArrayList<Region>() : regionList;
    }

    public void setRegionList(List<Region> regionList) {
        this.regionList = regionList;
    }
}
