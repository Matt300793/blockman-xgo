package com.sandboxol.mgs.teammgr;

import static io.grpc.MethodDescriptor.generateFullMethodName;
import static io.grpc.stub.ClientCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncUnimplementedStreamingCall;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.0.0)",
    comments = "Source: pteammgr.proto")
public class TeammgrGrpc {

  private TeammgrGrpc() {}

  public static final String SERVICE_NAME = "teammgr.Teammgr";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static final io.grpc.MethodDescriptor<TeamRequest,
      TeamResponse> METHOD_TEAM =
      io.grpc.MethodDescriptor.create(
          io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING,
          generateFullMethodName(
              "teammgr.Teammgr", "Team"),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(TeamRequest.getDefaultInstance()),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(TeamResponse.getDefaultInstance()));
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static final io.grpc.MethodDescriptor<LocalTeamsRequest,
      LocalTeamsResponse> METHOD_LOCAL_TEAMS =
      io.grpc.MethodDescriptor.create(
          io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING,
          generateFullMethodName(
              "teammgr.Teammgr", "LocalTeams"),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(LocalTeamsRequest.getDefaultInstance()),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(LocalTeamsResponse.getDefaultInstance()));

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static TeammgrStub newStub(io.grpc.Channel channel) {
    return new TeammgrStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static TeammgrBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new TeammgrBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary and streaming output calls on the service
   */
  public static TeammgrFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new TeammgrFutureStub(channel);
  }

  /**
   */
  public static abstract class TeammgrImplBase implements io.grpc.BindableService {

    /**
     * <pre>
     * team op
     * </pre>
     */
    public io.grpc.stub.StreamObserver<TeamRequest> team(
        io.grpc.stub.StreamObserver<TeamResponse> responseObserver) {
      return asyncUnimplementedStreamingCall(METHOD_TEAM, responseObserver);
    }

    /**
     */
    public io.grpc.stub.StreamObserver<LocalTeamsRequest> localTeams(
        io.grpc.stub.StreamObserver<LocalTeamsResponse> responseObserver) {
      return asyncUnimplementedStreamingCall(METHOD_LOCAL_TEAMS, responseObserver);
    }

    @Override public io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            METHOD_TEAM,
            asyncBidiStreamingCall(
              new MethodHandlers<
                TeamRequest,
                TeamResponse>(
                  this, METHODID_TEAM)))
          .addMethod(
            METHOD_LOCAL_TEAMS,
            asyncBidiStreamingCall(
              new MethodHandlers<
                LocalTeamsRequest,
                LocalTeamsResponse>(
                  this, METHODID_LOCAL_TEAMS)))
          .build();
    }
  }

  /**
   */
  public static final class TeammgrStub extends io.grpc.stub.AbstractStub<TeammgrStub> {
    private TeammgrStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeammgrStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected TeammgrStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeammgrStub(channel, callOptions);
    }

    /**
     * <pre>
     * team op
     * </pre>
     */
    public io.grpc.stub.StreamObserver<TeamRequest> team(
        io.grpc.stub.StreamObserver<TeamResponse> responseObserver) {
      return asyncBidiStreamingCall(
          getChannel().newCall(METHOD_TEAM, getCallOptions()), responseObserver);
    }

    /**
     */
    public io.grpc.stub.StreamObserver<LocalTeamsRequest> localTeams(
        io.grpc.stub.StreamObserver<LocalTeamsResponse> responseObserver) {
      return asyncBidiStreamingCall(
          getChannel().newCall(METHOD_LOCAL_TEAMS, getCallOptions()), responseObserver);
    }
  }

  /**
   */
  public static final class TeammgrBlockingStub extends io.grpc.stub.AbstractStub<TeammgrBlockingStub> {
    private TeammgrBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeammgrBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected TeammgrBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeammgrBlockingStub(channel, callOptions);
    }
  }

  /**
   */
  public static final class TeammgrFutureStub extends io.grpc.stub.AbstractStub<TeammgrFutureStub> {
    private TeammgrFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeammgrFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected TeammgrFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeammgrFutureStub(channel, callOptions);
    }
  }

  private static final int METHODID_TEAM = 0;
  private static final int METHODID_LOCAL_TEAMS = 1;

  private static class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final TeammgrImplBase serviceImpl;
    private final int methodId;

    public MethodHandlers(TeammgrImplBase serviceImpl, int methodId) {
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
        case METHODID_TEAM:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.team(
              (io.grpc.stub.StreamObserver<TeamResponse>) responseObserver);
        case METHODID_LOCAL_TEAMS:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.localTeams(
              (io.grpc.stub.StreamObserver<LocalTeamsResponse>) responseObserver);
        default:
          throw new AssertionError();
      }
    }
  }

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    return new io.grpc.ServiceDescriptor(SERVICE_NAME,
        METHOD_TEAM,
        METHOD_LOCAL_TEAMS);
  }

}
