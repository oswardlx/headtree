$(function () {
    var size = window.g
    var x = 1;
    $('#b1').click(function () {
        if (x < 2) {
            $('#p1').html("我就知道是太阳，那你猜我喜欢太阳还是月亮？");
            x++;
        } else {
            alert("错，我喜欢你");
        }
    });

    $('#b2').click(function () {
        if (x < 2) {
            $('#p1').html("我就知道是月亮，那你猜我喜欢太阳还是月亮？");
            x++;
        } else {
            alert("错，我喜欢你");
        }
    });
});


