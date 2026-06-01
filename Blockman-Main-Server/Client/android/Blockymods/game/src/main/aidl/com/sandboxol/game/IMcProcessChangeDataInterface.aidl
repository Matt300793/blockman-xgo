// IMcProcessChangeDataInterface.aidl
package com.sandboxol.game;

// Declare any non-default types here with import statements
interface IMcProcessChangeDataInterface {
    void buildRewardSettlement(int gold, int experience, int activeValues);
    void onlineTimeSettlement(int lv, int maxExp, int exp);
    void doHeartBeat();
}
