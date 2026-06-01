package com.sandboxol.blockmango.entity;

import java.io.Serializable;

/**
 * Created by Jimmy on 2016/9/22 0022.
 */

public class Talent implements Serializable {

    private String tid;

    private int level;

    private float bonus;

    private float nextbonus;

    private float incbonus;

    private float price;

    private boolean isChecked;

    public String getTid() {
        return tid;
    }

    public void setTid(String tid) {
        this.tid = tid;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public float getBonus() {
        return bonus;
    }

    public void setBonus(float bonus) {
        this.bonus = bonus;
    }

    public float getNextbonus() {
        return nextbonus;
    }

    public void setNextbonus(float nextbonus) {
        this.nextbonus = nextbonus;
    }

    public float getIncbonus() {
        return incbonus;
    }

    public void setIncbonus(float incbonus) {
        this.incbonus = incbonus;
    }

    public float getPrice() {
        return price;
    }

    public void setPrice(float price) {
        this.price = price;
    }

    public boolean isChecked() {
        return isChecked;
    }

    public void setChecked(boolean checked) {
        isChecked = checked;
    }
}
