package com.sandboxol.game.interfaces;

import com.sandboxol.mgs.connector.QueueResponse;
import com.sandboxol.mgs.connector.TeamQueueResponse;

import io.grpc.Status;

/**
 * Created by Mr.Luo on 16/8/8.
 */
public interface IConnectorListener {
    void onNext(QueueResponse queueResponse);

    void onTeamNext(TeamQueueResponse response);

    void onError(Status t);

    void onCompleted();

    void onTiming(String time);
}
