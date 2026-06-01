
function restartService(name) {
    if (!confirm("确定重启"+name+"服务吗？")) {
        return
    }

    var btn = document.getElementById('btn-'+name)
    if (btn) {
        btn.setAttribute('disabled', 'disabled')
        btn.innerHTML = "Restarting..."
        btn.style.color = 'orange';
    }

    var xhr = new XMLHttpRequest();
    xhr.open('POST', '/api/tasks');
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function () {
        if (xhr.status === 200) {
            alert('Request success: ' + xhr.responseText);
        } else if (xhr.status !== 200) {
            alert('Request failed.  Returned status of ' + xhr.status);
        }
        // location.reload()
    };
    xhr.send(encodeURI('name=' + name));
}

function reloadPage() {
    window.location.reload(true);
}

// setInterval(reloadPage, 3000);