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
  eventActionClick();
  console.log(1);
};
$(document).ready(reloadEvents);
$(document).on("page:receive",reloadEvents);

var checkTableAction = function (model, _this, event) {
  var actions = $(event.currentTarget).find("action");
  actions.each(function(index, action) {
    var $action = $(action);
    var btn_group = $action.parent("td").find(".btn-group").length > 0 ? $action.parent("td").find(".btn-group") : $("<div/>").addClass('btn-group');
    $action.parent("td").append(btn_group);
    if(typeof($action.attr("edit")) != "undefined") {
      $("<a/>").addClass('btn btn-sm').attr("href", ["/admin", model, $action.attr('id'),"edit"].join("/")).addClass("btn-warning").html('<i class="fa fa-pencil-square-o"></i>').appendTo(btn_group);
    }
    if(typeof($action.attr("remove")) != "undefined") {
      $("<a/>").addClass('btn btn-sm').attr("href", ["/admin", model, $action.attr('id')].join("/")).attr('data-method','delete').attr("confirm", "Are you sure?").addClass("btn-danger").html('<i class="fa fa-trash-o"></i>').appendTo(btn_group);
    }
  });
  actions.remove();
}

function blur(is_blur) {
  if (is_blur) {
    if ($("blur-bg").length == 0) $("body").append('<div class="blur-bg layout_2"></div>');
    $("body").addClass("blur");
  } else {
    $("body").removeClass("blur");
  }
}