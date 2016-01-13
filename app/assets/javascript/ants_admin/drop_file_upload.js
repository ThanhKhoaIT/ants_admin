function dropFileUpload(obj) {
  var not_upload_file = false;

  $("img.library_index").mousedown(function(event) {
    not_upload_file = true;
  });
  $("img.library_index").mouseup(function(event) {
    not_upload_file = false;
  });

  obj.on('dragenter', function (e) {
    if (!not_upload_file) {
      $(this).addClass("drag");
    }
    e.stopPropagation();
    e.preventDefault();
  });

  obj.on('dragleave', function (e) {
    $(this).removeClass("drag");
  })

  obj.on('dragover', function (e) {
    if (!not_upload_file) {
      $(this).addClass("drag");
    }
    e.stopPropagation();
    e.preventDefault();
  });

  obj.on('drop', function (e) {
    if (!not_upload_file) {
      e.preventDefault();
      AntsAdmin.uploadFiles = e.originalEvent.dataTransfer.files;

      var reader = new FileReader();
      reader.onload = function (e) {
        var img = $('img#drag_drop_review');
        img.attr('src', e.target.result);
      }
      reader.readAsDataURL(AntsAdmin.uploadFiles[0]);
    }
  });
}
