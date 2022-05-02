$("#images > div:gt(0)").hide();

setInterval(function() {
  $('#images > div:first')
    .fadeOut(1000)
    .next()
    .fadeIn(1000)
    .end()
    .appendTo('#images');
},  3000);

$("#text > div:gt(0)").hide();

setInterval(function() {
  $('#text > div:first')
    .fadeOut(1000)
    .next(5000)
    .fadeIn(1000)
    .end()
    .appendTo('#text');
},  3000);

setInterval(function() {
    $("#square").animate({left:2385}).animate({top:1185}).animate({left:0}).animate({top:0});
})

setInterval(function() {
    $("#square2").animate({left:2395}).animate({top:1195}).animate({left:0}).animate({top:10});
})