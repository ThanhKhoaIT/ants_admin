window.popup = function(opts) {
  var opts = $.extend({
    message: "Are you sure?",
    yesClick: function(){},
    noClick: function(){}
  }, opts);
  
  var yes_or_no = '<div class="popup-ants-admin layout_3"><span class="message">Are you sure?</span><div class="popup-footer"><button class="btn btn-success btn-sm">Yes</button><button class="btn btn-warning btn-sm">No</button></div></div>';
  
  window.clearPopup = function() {
    blur(false);
    $(".popup-ants-admin").remove();
  }
  
  blur(true);
  $("body").append(yes_or_no);
  
  $(".popup-ants-admin").find(".message").html(opts.message);
  $(".popup-ants-admin").find(".btn-success").click(function(event){opts.yesClick(event); window.clearPopup()});
  $(".popup-ants-admin").find(".btn-warning").click(function(event){opts.noClick(event); window.clearPopup()});
}