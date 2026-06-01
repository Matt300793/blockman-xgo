package com.sandboxol.game.interfaces;

import com.sandboxol.mgs.teammgr.LocalTeamsResponse;
import com.sandboxol.mgs.teammgr.TeamResponse;

import io.grpc.Status;

/**
 * Created by Mr.Luo on 2016/10/28.
 */

public interface ITeamManagerListener {

    void onTeamNext(TeamResponse response);

    void onTeamError(Status t);

    void onTeamCompleted();

    void onLocalTeamsNext(LocalTeamsResponse response);

    void onLocalTeamsError(Status t);

    void onLocalTeamsCompleted();
}
