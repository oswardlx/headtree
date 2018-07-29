
function check_uname() {
    var xhr = getXhr();
    var uri = 'check_name/check_uname.ht?username='+$('#inputEmail');
    xhr.open('get',encodeURI(uri),true)
    xhr.onreadystatechange=function () {
        if(xhr.readyState=4&&xhr.status==200){
            var txt = xhr.responseText;
            $('usrname_msg').innerHTML=txt;
        }
    };
    xhr.send(null);
}