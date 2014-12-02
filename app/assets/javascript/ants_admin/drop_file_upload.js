function dropFileUpload(obj) {
  obj.on('dragenter', function (e) {
    $(this).addClass("drag");
    e.stopPropagation();
    e.preventDefault();
  });

  obj.on('dragleave', function (e) {
    $(this).removeClass("drag");
  })

  obj.on('dragover', function (e) {
    $(this).addClass("drag");
    e.stopPropagation();
    e.preventDefault();
  });

  obj.on('drop', function (e) {
    e.preventDefault();
    AntsAdmin.uploadFiles = e.originalEvent.dataTransfer.files;
  
    var reader = new FileReader();
    reader.onload = function (e) {
      var img = $('img#drag_drop_review');
      img.attr('src', e.target.result);
    }
    reader.readAsDataURL(AntsAdmin.uploadFiles[0]);

  });
}
