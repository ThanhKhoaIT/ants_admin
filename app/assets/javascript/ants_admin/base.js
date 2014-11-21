window.AntsAdmin = window.AntsAdmin || {histories: []};

function setRlangCookie(cname, cvalue, days) {
  var d = new Date();
  if (typeof(days) == "undefined") {
    days = 1
  }
  d.setTime(d.getTime() + (days*24*60*60*1000));
  var expires = "expires="+d.toGMTString();
  document.cookie = cname + "=" + cvalue + "; " + expires + ";path=/";
}

function getRlangCookie(cname) {
  var name = cname + "=";
  var ca = document.cookie.split(';');
  for(var i=0; i<ca.length; i++) {
    var c = ca[i].trim();
    if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
  }
  return "";
}

window.notification = function (text, success) {
  $("#notification").html(text).addClass(success ? 'success' : 'error');
  setTimeout(function() {
    $("#notification").removeClass(success ? 'success' : 'error');
  }, 5000);
}

function showInfo() {
  $(".username_show").html(getRlangCookie("username"));
  $(".logout").click(function(event) {
    event.preventDefault();
    $(".logout_dialog").dialog({
      resizable: false,
      height:140,
      modal: true,
      buttons: {
        Yes: function() {
          $(this).dialog("close");
          setRlangCookie("token", "", -1);
          setRlangCookie("username", "", -1);
          window.location = "/express_translate";
        },
        No: function() {
          $(this).dialog("close");
        }
      }
    })
  });
}

function openInNewTab(url) {
  var win = window.open(url, '_blank');
  win.focus();
}

function blur(is_blur) {
  if (is_blur) {
    if ($("blur-bg").length == 0) $("body").append('<div class="blur-bg layout_2"></div>');
    $("body").addClass("blur");
  } else {
    $("body").removeClass("blur");
  }
}


var checkBackAction = function() {
  setTimeout(function() {
    if (window.location.pathname != "/admin") $("#back_action").fadeIn();
  }, 100);
};
var eventActionClick = function() {
  $("a[confirm]").unbind("click");
  $("a[confirm]").click(function(event){
    var message = $(event.curentTarget).attr("confirm");
    return window.confirm(message);
    // window.waitForPopup = true;
//     var isSayYes = false;
//     window.popup({
//       message: $(event.curentTarget).attr("confirm"),
//       yesClick: function(event_click) {isSayYes=true; window.waitForPopup=false},
//       noClick: function(event_click) {window.waitForPopup=false}
//     });
//     while(window.waitForPopup){setTimeout(function(){},300)};
//     return isSayYes;
  })
};

var reloadEvents = function () {
  checkBackAction();
};

function backupStatus() {
  window.AntsAdmin.histories.push(window.location.href);
}

function loadScripts(){
  
  var cursorPosition = { x: -1, y: -1 };
  $(document).mousemove(function(event) {
      cursorPosition.x = event.pageX;
      cursorPosition.y = event.pageY;
  });
  
  $(document).delegate("td .show-btn-list", "click", function(event) {return false})
  $(document).delegate("td .show-btn-list", "mouseenter", function(event) {
    $("td .btn-list").hide();
    var ul = $(event.currentTarget).parent("td").find(".btn-list");
    ul.css({
      top: cursorPosition.y,
      left: cursorPosition.x
    })
    ul.fadeIn();
    return false;
  })
  
  $(document).delegate("td .show-btn-list", "mouseleave", function(event) {
    $(event.currentTarget).parent("td").find(".btn-list").hide();
    return false;
  })
  
  $(document).delegate("a.active-link", "click", function(event) {
    var statusShow = function(status) {
      _this.removeClass("btn-primary btn-warning actived waiting");
      if (status=="actived") {
        _this.addClass("btn-primary actived");
      } else if (status=="deactived") {
        _this.addClass("btn-warning");
      } else if (status=="waiting") {
        _this.addClass("waiting");
      }
    }
    
    var _this = $(event.currentTarget);
    statusShow("waiting");
    $.ajax({
      type: "POST",
      url: _this.attr("href"),
      success: function (data) {
        if (data.success) {
          if (data.actived) {
            statusShow("actived");
          } else {
            statusShow("deactived");
          }
        }
      },
      error: function () {
        statusShow("error");
      }
    })
    return false;
  })
  
  // $(document).delegate("#back_action", "click", function(event) {
//     Turbolinks.visit(window.AntsAdmin.histories[window.AntsAdmin.histories.length - 1]);
//     window.AntsAdmin.histories.pop(1);
//     return false;
//   })
}


$(document).ready(reloadEvents);
$(document).ready(loadScripts);
$(document).on("page:receive",reloadEvents);
$(document).on("page:fetch", backupStatus);