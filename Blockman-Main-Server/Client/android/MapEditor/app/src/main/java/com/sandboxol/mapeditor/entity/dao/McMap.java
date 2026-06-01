package com.sandboxol.mapeditor.entity.dao;

import org.greenrobot.greendao.annotation.Entity;
import org.greenrobot.greendao.annotation.Generated;
import org.greenrobot.greendao.annotation.Id;
import org.greenrobot.greendao.annotation.Index;

/**
 * Created by Jimmy on 2017/11/29 0029.
 */
@Entity
public class McMap {

    @Id(autoincrement = true)
    private Long id;
    @Index
    private String name;
    private String image;
    private long size;

    @Generated(hash = 1393933002)
    public McMap(Long id, String name, String image, long size) {
        this.id = id;
        this.name = name;
        this.image = image;
        this.size = size;
    }

    @Generated(hash = 6587589)
    public McMap() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }
}
