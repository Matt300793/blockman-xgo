package com.sandboxol.game.interfaces;

/**
 * Created by Mr.Luo on 16/5/24.
 */
public interface IBulletinUpdateListener<T> {
    void onItemUpdate(T t, String gameId, String status);

    void onItemClose(T t, String gameId);
}
