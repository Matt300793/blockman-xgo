package com.sandboxol.clothes;

import android.opengl.GLSurfaceView;
import android.os.Message;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class EchoesRenderer implements GLSurfaceView.Renderer {
    static {
        System.loadLibrary("gnustl_shared");
        System.loadLibrary("ClothesPreview");
    }

    private static final String LOGTAG = "EchoesRenderer";
    private int mScreenWidth;
    private int mScreenHeight;
    private EchoesHandler mMainHandler;

    boolean mIsActive = false;
    private boolean m_bInitOK;

    private static final float OBJECT_SCALE_FLOAT = 50.0f;

    public void setScreenWidthAndHeight(final int pSurfaceWidth, final int pSurfaceHeight) {
        this.mScreenWidth = pSurfaceWidth;
        this.mScreenHeight = pSurfaceHeight;
    }

    public int getScreenWidth() {
        return mScreenWidth;
    }

    public int getScreenHeight() {
        return mScreenHeight;
    }

    public void setInitOK(boolean flag) {
        m_bInitOK = flag;
    }

    public void SetMainHandler(EchoesHandler handler) {
        mMainHandler = handler;
    }

    // ===========================================================
    // Methods for/from SuperClass/Interfaces
    // ===========================================================
    @Override
    public void onSurfaceCreated(final GL10 pGL10, final EGLConfig pEGLConfig) {
        m_bInitOK = false;
        Message msg = new Message();
        msg.what = EchoesHandler.HANDLER_GL_INIT_OK;
        mMainHandler.sendMessage(msg);
    }

    public void SizeChanged(int _width, int _height) {
        EchoesRenderer.nativeOnSurfaceChanged(_width, _height);
    }

    @Override
    public void onSurfaceChanged(final GL10 pGL10, final int pWidth, final int pHeight) {
        SizeChanged(pWidth, pHeight);
    }

    static int nCount = 0;
    static boolean init = false;

    @Override
    public void onDrawFrame(final GL10 gl) {
        try {
            if (m_bInitOK) {
                EchoesRenderer.nativeRender();
            }
        } catch (Exception e) {
            System.out.println("gl thread exception");
        }
    }

    // ===========================================================
    // Methods
    // ===========================================================
    private static native void nativeTouchesBegin(final int pID, final float pX, final float pY);

    private static native void nativeTouchesEnd(final int pID, final float pX, final float pY);

    private static native void nativeTouchesMove(final int[] pIDs, final float[] pXs, final float[] pYs);

    private static native void nativeTouchesCancel(final int[] pIDs, final float[] pXs, final float[] pYs);

    private static native boolean nativeKeyDown(final int pKeyCode);

    private static native void nativeRender();

    public static native void nativeInit(String strRootPath, String strConfigPath, final int pWidth, final int pHeight, int sex);

    private static native void nativeOnSurfaceChanged(final int pWidth, final int pHeight);

    private static native void nativeOnPause();

    private static native void nativeOnResume();

    private static native void nativeChangeParts(String masterName, String slaveName);

    private static native void nativeChangeSex(int sex);

    private static native void nativeChangeDecorations(int id);

    private static native void nativeChangeAction(int id);

    private static native void nativeChangeSkinColor(int id);

    private static native void nativeChangeActorSize(float w, float h);

    private static native void nativeOnGetPhoneType(String strType);

    // java call game interface define
    public static native int nativeCheckVersion(String strRootPath);

    public static native int nativeUpdateFiles();

    public static native float nativeGetDownloadPercent();

    public static native int nativeGetDownloadState();

    public static native int nativeGetTotalDownloadSize();

    public static native int nativeGetCurrentDownloadSize();

    public static native String nativeGetLocalVersion();

    public static native String nativeGetServerVersion();

    public void handleActionDown(final int pID, final float pX, final float pY) {
        EchoesRenderer.nativeTouchesBegin(pID, pX, pY);
    }

    public void handleActionUp(final int pID, final float pX, final float pY) {
        EchoesRenderer.nativeTouchesEnd(pID, pX, pY);
    }

    public void handleActionCancel(final int[] pIDs, final float[] pXs, final float[] pYs) {
        EchoesRenderer.nativeTouchesCancel(pIDs, pXs, pYs);
    }

    public void handleActionMove(final int[] pIDs, final float[] pXs, final float[] pYs) {
        EchoesRenderer.nativeTouchesMove(pIDs, pXs, pYs);
    }

    public void handleKeyDown(final int pKeyCode) {
        EchoesRenderer.nativeKeyDown(pKeyCode);
    }

    public void handleOnPause() {
        EchoesRenderer.nativeOnPause();
    }

    public void handleOnResume() {
        EchoesRenderer.nativeOnResume();
    }

    public void handleInitGame(final String strRootPath, final String strConfigPath, final int nWidth, final int nHeight, int sex) {
        EchoesRenderer.nativeInit(strRootPath, strConfigPath, nWidth, nHeight, sex);
    }


    public void handleChangeParts(String masterName, String slaveName) {
        EchoesRenderer.nativeChangeParts(masterName, slaveName);
    }

    public void handleChangeSex(int sex) {
        EchoesRenderer.nativeChangeSex(sex);
    }

    public void handleChangeDecorations(int id) {
        EchoesRenderer.nativeChangeDecorations(id);
    }

    public void handleChangeAction(int id) {
        EchoesRenderer.nativeChangeAction(id);
    }

    public void handleChangeSkinColor(int id) {
        EchoesRenderer.nativeChangeSkinColor(id);
    }

    public void handleChangeActorSize(float w, float h) {
        EchoesRenderer.nativeChangeActorSize(w,h);
    }

}
