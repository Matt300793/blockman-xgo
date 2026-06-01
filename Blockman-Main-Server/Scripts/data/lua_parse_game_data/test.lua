local seri
try {
    
    seri = require "seri"

    catch {
        -- 发生异常后，被执行
        function (errors)
            print(errors)
        end
    }
}


function toTable(txt)
    print("call toTable", txt)
    local dataTable = seri.deseristring_string(misc.base64_decode(txt))
    print("dataTable:",dataTable)
    return dataTable
end
 
-- 入口函数,实现反射函数调用
function functionCall(func_name,params)
    local is_true,result
    local sandBox = function(func_name,params)
        local result
        result = _G[func_name](params)
        return result
    end
    is_true,result= pcall(sandBox,func_name,params)
    return result
end