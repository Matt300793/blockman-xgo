# -*- coding: utf-8 -*-
import traceback
import os
try:
    from lupa import LuaRuntime
except:
    os.system("pip install lupa")
    from lupa import LuaRuntime

import threading
 
class Executor(threading.Thread):
    """
        执行lua的线程类
    """
    lock = threading.RLock()
    luaScriptContent = None
    luaRuntime = None
 
    def __init__(self,api,params):
        threading.Thread.__init__(self)
        self.params = params
        self.api = api
 
    def run(self):
        try:
            # 执行具体的函数,返回结果打印在屏幕上
            luaRuntime = self.getLuaRuntime()
            rel = luaRuntime(self.api, self.params)
            print(rel)
        except Exception as e:
            print(e.message)
            traceback.extract_stack()
 
 
    def getLuaRuntime(self):
        """
            从文件中加载要执行的lua脚本,初始化lua执行环境
        """
 
        # 上锁,保证多个线程加载不会冲突
        if Executor.lock.acquire():
            if Executor.luaRuntime is None:
                fileHandler = open('./test.lua')
                content = ''
                try:
                    content = fileHandler.read()
                except Exception(e):
                    print(e.message)
                    traceback.extract_stack()
 
                # 创建lua执行环境
                Executor.luaScriptContent = content
                luaRuntime = LuaRuntime()
                luaRuntime.execute(content)
 
                # 从lua执行环境中取出全局函数functionCall作为入口函数调用,实现lua的反射调用
                g = luaRuntime.globals()
                function_call = g.functionCall
                Executor.luaRuntime = function_call
            Executor.lock.release()
 
        return Executor.luaRuntime
 
 
if __name__ == "__main__":
 
    # 在两个线程中分别执行lua中test1,test2函数
    executor1 = Executor('toTable',"zgYAAAYsc3RvcmUGAFRzaWduSW5EYXRhBgAkdmFycwZ0Y2hhdERhdGFSZXBvcnQGAABEY2hhcHRlcnMGAER0YXNrRGF0YQYAVHRhc2tGaW5pc2gGAGRyZWNoYXJnZURhdGEGXHN1bVJlY2hhcmdlBkxjdXJyZW50SWQKAUxyZW1pbmREYXkCAAA0d2FsbGV0BnRncmVlbl9jdXJyZW5jeQYsY291bnQiyC0DAAAsZ29sZHMGLGNvdW50AgBMZ0RpYW1vbmRzBixjb3VudBJlXQAALGN1ckhwQgAAAAAAAFlALGN1clZwQgAAAAAAAFlAJHRyYXkGNHN5c3RlbR4GTHRyYXlfZGF0YQZEY2FwYWNpdHkKAQBcY3JlYXRlX2RhdGEGJHR5cGUKAVxtYXhDYXBhY2l0eQoBRGNhcGFjaXR5CgEATGl0ZW1fZGF0YQYAAAZMdHJheV9kYXRhBkRjYXBhY2l0eQoCAFxjcmVhdGVfZGF0YQYkdHlwZQoCXG1heENhcGFjaXR5CgJEY2FwYWNpdHkKAgBMaXRlbV9kYXRhBgAABkx0cmF5X2RhdGEGRGNhcGFjaXR5CgoAXGNyZWF0ZV9kYXRhBiR0eXBlCgNcbWF4Q2FwYWNpdHkKCkRjYXBhY2l0eQoKAExpdGVtX2RhdGEGAAACBkx0cmF5X2RhdGEGRGNhcGFjaXR5CgoAXGNyZWF0ZV9kYXRhBiR0eXBlAlxtYXhDYXBhY2l0eQoKRGNhcGFjaXR5CgoATGl0ZW1fZGF0YQYAAAoUBkx0cmF5X2RhdGEGRGNhcGFjaXR5CgMAXGNyZWF0ZV9kYXRhBiR0eXBlChRcbWF4Q2FwYWNpdHkKA0RjYXBhY2l0eQoDAExpdGVtX2RhdGEGAAAS6AMGTHRyYXlfZGF0YQZEY2FwYWNpdHkKCgBcY3JlYXRlX2RhdGEGJHR5cGUS6ANcbWF4Q2FwYWNpdHkKCkRjYXBhY2l0eQoKAExpdGVtX2RhdGEGAAAAACRidWZmBgAccGV0BgBcdHJlYXN1cmVib3gGAHxyYW5rU2NvcmVSZWNvcmQGADR2YWx1ZXMGlFJlcG9ydEZpcnN0T3V0SG9sZQmUZmluaXNoUm9iRG9udXRTaG9wCXRyb2JiZXJJdGVtTGlzdAYArFJlcG9ydEZpcnN0UG9saWNlRG9vcgmkUmVwb3J0Rmlyc3RFbnRlckJhbmsJdFBhY2thZ2VFbmxhcmdlCgd0UmVwb3J0Rmlyc3RCb3gJXE1vbnRobHlDYXJkBkxsYXN0QXdhcmQCNGV4cGlyeQIAzFJlcG9ydFJvbGVGaXJzdE9ubGluZVRpbWUGNFJvYmJlcgk0UG9saWNlCQCsZmlyc3RQb2xpY2VTZWxlY3RSb2xlCcxSZXBvcnRGaXJzdFNlbGVjdENyaW1pbmFsCTxjaGF0Q250EikEtGZpcnN0UHJpc29uTGVhdmVEYW5nZXIJrFJlcG9ydEZpcnN0RW50ZXJEb251dAmsUmVwb3J0Rmlyc3RFbGVjdHJvbmljCbRSZXBvcnRGaXJzdE1hbmhvbGVIb2xlCXRpc1Nob3dRdWVzdGlvbgm8UmVwb3J0Rmlyc3RTZWxlY3RQb2xpY2UJtGZpcnN0UHJpc29uRW50ZXJXZWFwb24JdFJlcG9ydEZpcnN0T3V0CZxSZXBvcnRGaXJzdEVudGVyR2FzCSxpc1ZpcAlMZ3VpZGVTdGVwLHN0ZXAyrGZpcnN0UHJpc29uU2VsZWN0Um9sZQmUUmVwb3J0Rmlyc3RNYW5ob2xlCURhdXRoTGlzdAY0Y2FyXzA2Iv////98bW9iaWxlX2d1bl9zaG9wIv////9UZ3VuX3Bpc3RvbCL/////PGd1bl91emki/////1RndW5fc25pcGVyIv////9sbW9iaWxlX2dhcmFnZSL/////NGNhcl8wNSL/////zHBhY2thZ2VfZW5sYXJnZV9wcml2aWxlZ2Ui/////0xndW5fcmlmbGUi/////2x2aXBfcHJpdmlsZWdlIv////9cZ3VuX3Nob3RndW4i/////3RndW5fc2Nhcl9nY3ViZSL/////ALRmaXJzdFBvbGljZUxlYXZlRGFuZ2VyCVRtZXJpdFZhbHVlEjyltGZpcnN0UG9saWNlRW50ZXJXZWFwb24JdHBvbGljZUl0ZW1MaXN0LpRteXBsdWdpbi9ndW5fbTE5MTF8bXlwbHVnaW4vZ3VuX20zhG15cGx1Z2luL2d1bl9hd3DEbXlwbHVnaW4vcHJvcHNfaGFuZGN1ZmZzbG15cGx1Z2luL2NhcmQAAAA=")
    executor1.start()
    executor1.join()