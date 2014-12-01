window.AntsAdmin = window.AntsAdmin || {};

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

function executeFunctionByName(functionName, context, args) {
  var args = [].slice.call(arguments).splice(2);
  var namespaces = functionName.split(".");
  var func = namespaces.pop();
  for(var i = 0; i < namespaces.length; i++) {
    context = context[namespaces[i]];
  }
  return context[func].apply(this, args);
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
    if ($(".blur-bg").length == 0) $("body").append('<div class="blur-bg layer_3"></div>');
    $("body").addClass("blur");
  } else {
    $("body").removeClass("blur");
  }
}

function waiting(is_waiting) {
  blur(is_waiting);
  if (is_waiting) {
    var html = '<div class="waiting_spinner"><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span><span></span></div>';
    
    if ($(".waiting_spinner").length == 0) $("body").append(html);//'<div class="waiting_spinner layer_4"></div>');
    
  } else {
    $(".waiting_spinner").remove();
  }
}

function updateSelectBox(link, arr) {
  var el    = arr[0];
  var model = arr[1];
  
  var right_side = $(".right-side");
  window.blur(true);
  var iframe = $("<iframe/>").attr('src', link).addClass('add_ajax layer_4').appendTo("body").hide();
  var close_iframe = $("<button/>").addClass('fa fa-times layer_4 close-iframe').appendTo("body").hide();
  setTimeout(function() {
    iframe.show().addClass('flipInX animated');
    close_iframe.fadeIn(1000);
  }, 300);
  
  close_iframe.click(function() {
    window.blur(false);
    iframe.remove();
    close_iframe.remove();
  })
  iframe.on("load",function(event){
    iframe.contents().find('input[type="checkbox"].flat-blue, input[type="radio"].flat-blue').iCheck({
      checkboxClass: 'icheckbox_flat-blue',
      radioClass: 'iradio_flat-blue'
    }); 
    
    var form = iframe.contents().find("form");
    if (form.length > 0) {   
      if (form.height() < 500) {
        iframe.height(form.height() + 81);
        iframe.contents().find('.add_popup').height(form.height() + 80);
      } else {
        iframe.height(500);
      }
      iframe.css('margin-top', -(iframe.height()/2))
      close_iframe.css('margin-top', -(iframe.height()/2) - 20)
      
      form.submit(function(event) {
        window.waiting(true);
        iframe.addClass('layer_2 blur_content');
        iframe.removeClass('layer_4');
        close_iframe.remove();
        iframe.css("opacity", 0);
      })
    }
    if (iframe.contents().find('.alert.alert-success.alert-dismissable').length > 0) {
      iframe.remove();
      close_iframe.remove();
      window.waiting(false);
      $.ajax({
        url: ['/admin',model,"select_box.json"].join("/"),
        success: function (data) {
          $(el + " option").remove();
          $.each(data.all, function(index, item) {
            $("<option/>").attr('value', item.id).html(item.text).appendTo($(el));
          })
          window.blur(false);
        }
      })
    }
  })
}

function loadReviewImage(files) {
  //$('#new_<%= @model_string.downcase %>').submit();
  var reader = new FileReader();
  reader.onload = function (e) {
    var img = $('#review_upload_image img');
    img.attr('src', e.target.result);
    var review = $("#review_upload_image_group");
    if (!review.hasClass('fadeInUp')) {
      review.removeAttr('class');
      setTimeout(function() {
        review.addClass("animated fadeInUp");
      }, 50)
    }
  }
  reader.readAsDataURL(files[0]);
}

function checkBackAction() {
  setTimeout(function() {
    var href = $(".breadcrumb li:nth-last-child(2) a").attr("href"),
        back_action = $("#back_action");
    back_action.removeClass("fa-refresh fa-tachometer fa-arrow-left");
    
      if (typeof(href) == "undefined") {    
        $("#back_action").addClass("fa-refresh");
        back_action.attr("href", "/admin");
      } else {
        if (href == "/admin") {
          $("#back_action").addClass("fa-tachometer");
        } else {
          $("#back_action").addClass("fa-arrow-left");
        }
        back_action.attr("href", href);
      }
    // var level = parseInt($.jStorage.get('back_level', '1'));
//     if (level > 1) $("#back_action").fadeIn();
//     if ($.jStorage.get('back_'+level+'_href') == window.location.pathname) $("#back_action").hide();
    

  }, 100);
};
function eventActionClick() {
  $("a[confirm]").unbind("click");
  $("a[confirm]").click(function(event){
    var message = $(event.curentTarget).attr("confirm");
    return window.confirm(message);
  })
};

function reloadEvents() {
  checkBackAction();
};

function loadScripts(){
  var cursorPosition = { x: -1, y: -1 };
  $(document).mousemove(function(event) {
      cursorPosition.x = event.pageX;
      cursorPosition.y = event.pageY;
  });

  $(document).delegate("td .show-btn-list", "click", function(event) {
    $(event.currentTarget).parents("td").addClass("show_list");
    return false;
  });
  $(document).delegate("td ul a.close_list", "click", function(event) {
    $(event.currentTarget).parents("td").removeClass("show_list");
    return false;
  });

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

  $(document).delegate("a[iframe_link]", "click", function(event) {
    var _this = $(event.currentTarget),
        link = _this.attr('iframe_link'),
        call = _this.attr('iframe_callback'),
        params = _this.attr('iframe_params');
    executeFunctionByName(call, window, link, params.split(','));
    return false;
  })
  
  $(document).delegate("td .select_edit a.fa.fa-cog", "click", function(event) {
    var _this = $(event.currentTarget).parents("td"),
        data = _this.find('data'),
        select_edit = _this.find(".select_edit"),
        text_show = select_edit.find("span"),
        type = data.attr('type'),
        id = data.attr('obj-id'),
        value = data.attr('value'),
        model = data.attr('model');
    
    _this.addClass("update_select");
    var selectbox = $("<select/>").appendTo(select_edit);
    var done = $("<a/>").addClass("fa fa-check btn btn-default disabled").appendTo(select_edit);
    var close_link = $("<a/>").addClass("fa fa-times").attr("href","#").appendTo(select_edit);
    
    var cancel = function () {
      selectbox.remove();
      done.remove();
      close_link.remove();
      text_show.show();
      _this.removeClass("update_select");
    }    
    
    $.ajax({
      url: ["/admin",type,"select_box.json"].join("/"),
      success: function (data) {
        text_show.hide();
        $.each(data.all, function(index, item) {
          selectbox.append($("<option/>").attr("value", item.id).html(item.text));
        })
        
        selectbox.val(value);
        selectbox.change(function(event) {
          if (selectbox.val() == value) {
            done.addClass("disabled");
          } else {
            done.removeClass("disabled");
          }
        })
        close_link.click(function(event) {cancel()});
        done.click(function(event) {
          $.ajax({
            url: ["","admin",model,id,"select"].join("/"),
            type: 'POST',
            data: {
              type: type,
              value: selectbox.val()
            },
            success: function (data) {
              if (data.success) {
                text_show.html(selectbox.find("option[value='"+selectbox.val()+"']").text());
              }
              cancel();
            }
          })
        })
      }
    })
    return false;
  })
  
  $(document).delegate("table.table tr", "click", function(event) {
    $('table.table tr').removeAttr('class');
    $(event.currentTarget).addClass('focus');
  })
  
  $(document).delegate(".blur-bg", "click", function(event) {
    $(".add_ajax.layer_4").removeClass("pulse animated flipInX");
    
    setTimeout(function() {
      $(".add_ajax.layer_4").addClass("pulse animated");
    }, 50);
  })
  
  $(document).delegate("#save_action", "click", function(event) {
    $(".content form").submit();
    return false;
  })
  
  $(document).delegate("#review_upload_image .btn-sm.btn-danger", "click", function(event) {
    $("#review_upload_image_group").removeClass("fadeInUp").addClass('fadeOutDown');
    return false;
  })
  
  $(document).delegate("#review_upload_image .btn-sm.btn-success", "click", function(event) {
    $("#review_upload_image_group").hide().parents("form").submit();
    window.waiting(true);
    return false;
  })
  
  $(document).delegate(".btn.btn-sm.btn-danger[data-method='delete']", "click", function(event) {
    window.waiting(true);
  })
  
  $(document).delegate(".action_drag_drop_cancel", "click", function(event) {
    $("#drop_files.content.drag").removeClass("drag");
    return false;
  })
  
  $(document).delegate(".action_drag_drop_upload", "click", function(event) {
    var fd = new FormData();
    fd.append('file', AntsAdmin.uploadFiles[i]);
    
    // var uploadURL ="/admin"; //Upload URL
//     var extraData ={}; //Extra Data.
//     var jqXHR=$.ajax({
//       xhr: function() {
//         var xhrobj = $.ajaxSettings.xhr();
//         if (xhrobj.upload) {
//           xhrobj.upload.addEventListener('progress', function(event) {
//             var percent = 0;
//             var position = event.loaded || event.position;
//             var total = event.total;
//             if (event.lengthComputable) {
//               percent = Math.ceil(position / total * 100);
//             }
//             //Set progress
//             status.setProgress(percent);
//           }, false);
//         }
//         return xhrobj;
//       },
//       url: uploadURL,
//       type: "POST",
//       contentType:false,
//       processData: false,
//       cache: false,
//       data: formData,
//       success: function(data){
//         status.setProgress(100);
//
//         //$("#status1").append("File upload Done<br>");
//       }
//     });
//
//     status.setAbort(jqXHR);
    
    AntsAdmin.uploadFiles = "";
    return false;
  })
  
  
}


$(document).ready(reloadEvents);
$(document).ready(loadScripts);
$(document).on("page:receive",reloadEvents);