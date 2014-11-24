$(document).ready(function() {
  $(document).delegate("a[back-href], button[back-href], input[back-href]", "click", function(event) {
    var level = $(event.currentTarget).attr("back-level"),
        href = $(event.currentTarget).attr("back-href");
    if (typeof(level) == 'undefined') {level = 1};
    $.jStorage.set('back_level', level, {});
    $.jStorage.set('back_'+level+'_href', href, {});
    
  })
  
  $(document).delegate("#back_action", "click", function(event) {
    var level = parseInt($.jStorage.get('back-level', '1'));
        href = $.jStorage.get('back_'+level+'_href', "/admin");
    if (level <= 1) {
      $.jStorage.deleteKey('back_level');
    }
    $.jStorage.set('back_level', level-1, {});
    window.location.pathname = href;
  })
})

function setBack(level, href) {
  $.jStorage.set('back_level', level, {});
  $.jStorage.set('back_'+level+'_href', href, {});
  checkBackAction();
}
