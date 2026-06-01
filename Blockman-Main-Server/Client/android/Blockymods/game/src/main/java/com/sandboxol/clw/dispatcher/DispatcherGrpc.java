package com.sandboxol.clw.dispatcher;

import static io.grpc.MethodDescriptor.generateFullMethodName;
import static io.grpc.stub.ClientCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncUnimplementedStreamingCall;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.0.0)",
    comments = "Source: pdispatcher.proto")
public class DispatcherGrpc {

  private DispatcherGrpc() {}

  public static final String SERVICE_NAME = "dispatcher.Dispatcher";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static final io.grpc.MethodDescriptor<ServerListRequest,
      ServerListResponse> METHOD_SERVER_LIST =
      io.grpc.MethodDescriptor.create(
          io.grpc.MethodDescriptor.MethodType.BIDI_STREAMING,
          generateFullMethodName(
              "dispatcher.Dispatcher", "ServerList"),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(ServerListRequest.getDefaultInstance()),
          io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(ServerListResponse.getDefaultInstance()));

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static DispatcherStub newStub(io.grpc.Channel channel) {
    return new DispatcherStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static DispatcherBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new DispatcherBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary and streaming output calls on the service
   */
  public static DispatcherFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new DispatcherFutureStub(channel);
  }

  /**
   */
  public static abstract class DispatcherImplBase implements io.grpc.BindableService {

    /**
     * <pre>
     * server list
     * </pre>
     */
    public io.grpc.stub.StreamObserver<ServerListRequest> serverList(
        io.grpc.stub.StreamObserver<ServerListResponse> responseObserver) {
      return asyncUnimplementedStreamingCall(METHOD_SERVER_LIST, responseObserver);
    }

    @Override public io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            METHOD_SERVER_LIST,
            asyncBidiStreamingCall(
              new MethodHandlers<
                ServerListRequest,
                ServerListResponse>(
                  this, METHODID_SERVER_LIST)))
          .build();
    }
  }

  /**
   */
  public static final class DispatcherStub extends io.grpc.stub.AbstractStub<DispatcherStub> {
    private DispatcherStub(io.grpc.Channel channel) {
      super(channel);
    }

    private DispatcherStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected DispatcherStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new DispatcherStub(channel, callOptions);
    }

    /**
     * <pre>
     * server list
     * </pre>
     */
    public io.grpc.stub.StreamObserver<ServerListRequest> serverList(
        io.grpc.stub.StreamObserver<ServerListResponse> responseObserver) {
      return asyncBidiStreamingCall(
          getChannel().newCall(METHOD_SERVER_LIST, getCallOptions()), responseObserver);
    }
  }

  /**
   */
  public static final class DispatcherBlockingStub extends io.grpc.stub.AbstractStub<DispatcherBlockingStub> {
    private DispatcherBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private DispatcherBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected DispatcherBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new DispatcherBlockingStub(channel, callOptions);
    }
  }

  /**
   */
  public static final class DispatcherFutureStub extends io.grpc.stub.AbstractStub<DispatcherFutureStub> {
    private DispatcherFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private DispatcherFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @Override
    protected DispatcherFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new DispatcherFutureStub(channel, callOptions);
    }
  }

  private static final int METHODID_SERVER_LIST = 0;

  private static class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final DispatcherImplBase serviceImpl;
    private final int methodId;

    public MethodHandlers(DispatcherImplBase serviceImpl, int methodId) {
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
        case METHODID_SERVER_LIST:
          return (io.grpc.stub.StreamObserver<Req>) serviceImpl.serverList(
              (io.grpc.stub.StreamObserver<ServerListResponse>) responseObserver);
        default:
          throw new AssertionError();
      }
    }
  }

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    return new io.grpc.ServiceDescriptor(SERVICE_NAME,
        METHOD_SERVER_LIST);
  }

}
