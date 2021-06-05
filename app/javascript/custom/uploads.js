$(function () {
  $('#fileUpload').on("change", function() {
    console.log("change fire");
    var i = $(this).prev('label').clone();
    var file = $('#fileUpload')[0].files[0].name;
    console.log(file);
    $('#fileUploadLabel').html('Selected File: ' + file);
  });
})
