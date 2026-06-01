package com.sandboxol.mgs.connector;

import static io.grpc.MethodDescriptor.generateFullMethodName;
import static io.grpc.stub.ClientCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncUnimplementedStreamingCall;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.0.0)",
    comments = "Source: connector.proto")
public class ConnectorGrpc {

  private ConnectorGrpc() {}

  public static final String SERVICE_NAME = "connector.Connector";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static final io.grpc.MethodDescriptor<QueueRequest,
      QueueResponse> METHOD_QUEUE =
      io.grpc.MethodDescriptor.create(
          io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING,
          generateFullMethodName(
              "connector.Connector", "Queue"),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(QueueRequest.getDefaultInstance()),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(QueueResponse.getDefaultInstance()));
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static final io.grpc.MethodDescriptor<TeamQueueRequest,
      TeamQueueResponse> METHOD_TEAM_QUEUE =
      io.grpc.MethodDescriptor.create(
          io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING,
          generateFullMethodName(
              "connector.Connector", "TeamQueue"),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(TeamQueueRequest.getDefaultInstance()),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(TeamQueueResponse.getDefaultInstance()));

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static ConnectorStub newStub(io.grpc.Channel channel) {
    return new ConnectorStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static ConnectorBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new ConnectorBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary and streaming output calls on the service
   */
  public static ConnectorFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new ConnectorFutureStub(channel);
  }

  /**
   */
  public static abstract class ConnectorImplBase implements io.grpc.BindableService {

    /**
     * <pre>
     * queue op
     * </pre>
     */
    public io.grpc.stub.StreamObserver<QueueRequest> queue(
        io.grpc.stub.StreamObserver<QueueResponse> responseObserver) {
      return asyncUnimplementedStreamingCall(METHOD_QUEUE, responseObserver);
    }

    /**
     */
    public io.grpc.stub.StreamObserver<TeamQueueRequest> teamQueue(
        io.grpc.stub.StreamObserver<TeamQueueResponse> responseObserver) {
      return asyncUnimplementedStreamingCall(METHOD_TEAM_QUEUE, responseObserver);
    }

    @Override public io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            METHOD_QUEUE,
            asyncBidiStreamingCall(
              new MethodHandlers<
                QueueRequest,
                QueueResponse>(
                  this, METHODID_QUEUE)))
          .addMethod(
            METHOD_TEAM_QUEUE,
            asyncBidiStreamingCall(
              new MethodHandlers<
                TeamQueueRequest,
                TeamQueueResponse>(
                  this, METHODID_TEAM_QUEUE)))
          .build();
    }
  }

  /**
   */
  public static final class ConnectorStub extends io.grpc.stub.AbstractStub<ConnectorStub> {
    private ConnectorStub(io.grpc.Channel channel) {
      super(channel);
    }

    private ConnectorStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected ConnectorStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new ConnectorStub(channel, callOptions);
    }

    /**
     * <pre>
     * queue op
     * </pre>
     */
    public io.grpc.stub.StreamObserver<QueueRequest> queue(
        io.grpc.stub.StreamObserver<QueueResponse> responseObserver) {
      return asyncBidiStreamingCall(
          getChannel().newCall(METHOD_QUEUE, getCallOptions()), responseObserver);
    }

    /**
     */
    public io.grpc.stub.StreamObserver<TeamQueueRequest> teamQueue(
        io.grpc.stub.StreamObserver<TeamQueueResponse> responseObserver) {
      return asyncBidiStreamingCall(
          getChannel().newCall(METHOD_TEAM_QUEUE, getCallOptions()), responseObserver);
    }
  }

  /**
   */
  public static final class ConnectorBlockingStub extends io.grpc.stub.AbstractStub<ConnectorBlockingStub> {
    private ConnectorBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private ConnectorBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected ConnectorBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new ConnectorBlockingStub(channel, callOptions);
    }
  }

  /**
   */
  public static final class ConnectorFutureStub extends io.grpc.stub.AbstractStub<ConnectorFutureStub> {
    private ConnectorFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private ConnectorFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected ConnectorFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new ConnectorFutureStub(channel, callOptions);
    }
  }

  private static final int METHODID_QUEUE = 0;
  private static final int METHODID_TEAM_QUEUE = 1;

  private static class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final ConnectorImplBase serviceImpl;
    private final int methodId;

    public MethodHandlers(ConnectorImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @Override
    @SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }

    @Override
    @SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_QUEUE:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.queue(
              (io.grpc.stub.StreamObserver<QueueResponse>) responseObserver);
        case METHODID_TEAM_QUEUE:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.teamQueue(
              (io.grpc.stub.StreamObserver<TeamQueueResponse>) responseObserver);
        default:
          throw new AssertionError();
      }
    }
  }

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    return new io.grpc.ServiceDescriptor(SERVICE_NAME,
        METHOD_QUEUE,
        METHOD_TEAM_QUEUE);
  }

}
