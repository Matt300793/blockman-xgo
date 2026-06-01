package com.sandboxol.mapeditor.entity.dao;

import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Generated;
import org.greenrobot.greendao.annotation.Id;
import org.greenrobot.greendao.annotation.Index;

/**
 * Created by Jimmy on 2017/12/2 0002.
 */
@Entity
public class McMapBackup {

    @Id(autoincrement = true)
    private Long id;
    @Index
    private long mapId;
    @Index
    private String name;
    private String image;
    private long time;

    @Generated(hash = 917053072)
    public McMapBackup(Long id, long mapId, String name, String image, long time) {
        this.id = id;
        this.mapId = mapId;
        this.name = name;
        this.image = image;
        this.time = time;
    }

    @Generated(hash = 1052006515)
    public McMapBackup() {
    }

    public Long getId() {
        return this.id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public long getMapId() {
        return this.mapId;
    }

    public void setMapId(long mapId) {
        this.mapId = mapId;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getImage() {
        return this.image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public long getTime() {
        return this.time;
    }

    public void setTime(long time) {
        this.time = time;
    }
}
