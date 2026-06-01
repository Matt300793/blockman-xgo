require(["ace/mode/yaml", "ace/theme/github"], function () {
    $('#editor').height(
        $(window).height() -
        $('nav').outerHeight(true) - 80
    );

    var editor = ace.edit("editor");
    editor.setTheme("ace/theme/github");
    editor.session.setMode("ace/mode/yaml");

    $('#editor').show()

    $('#btnSave').on('click', function(e) {
        e.preventDefault();
        $.post('api/config', {
            content: editor.getValue()
        }, function(response) {
            if (response == 'OK') {
                $.notify({
                    message: '修改配置成功'
                }, {
                    type: 'success'
                })
            } else {
                $.notify({
                    message: '修改失败'
                }, {
                    type: 'danger'
                })
            }
        })
    })
});