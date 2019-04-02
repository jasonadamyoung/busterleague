  Dropzone.autoDiscover = false;

  // Get the template HTML and remove it from the doument
  var previewNode = document.querySelector("#template");
  previewNode.id = "";
  var previewTemplate = previewNode.parentNode.innerHTML;
  previewNode.parentNode.removeChild(previewNode);

  var myDropzone = new Dropzone(document.body, { // Make the whole body a dropzone
    paramName: "upload[archivefile]",
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    acceptedFiles: ".zip",
    url: "/uploads/", // Set the url
    maxFiles: 1,
    uploadMultiple: false,
    timeout: 420000, // 7 minutes in milliseconds for my slow-ass internet
    previewTemplate: previewTemplate,
    autoQueue: false, // Make sure the files aren't queued until manually added
    previewsContainer: "#previews", // Define the container to display the previews
    clickable: ".fileinput-button" // Define the element that should be used as click trigger to select files.
  });

  // Update the total progress bar
  myDropzone.on("totaluploadprogress", function(progress) {
    document.querySelector("#total-progress .progress-bar").style.width = progress + "%";
  });

  myDropzone.on("sending", function(file) {
    // Show the total progress bar when upload starts
    document.querySelector("#total-progress").style.opacity = "1";
    var $qs = file.previewElement.querySelector(".queuestatus").innerHTML = "Uploading..."

    // And disable the global buttons
    document.querySelector("#actions .start").setAttribute("disabled", "disabled");
    document.querySelector("#actions .fileinput-button").setAttribute("disabled", "disabled");
    document.querySelector("#actions .cancel").setAttribute("disabled", "disabled");
  });

  // Hide the total progress bar when nothing's uploading anymore
  myDropzone.on("queuecomplete", function(progress) {
    document.querySelector("#total-progress").style.opacity = "0";
    // like highlander there can be only one
    document.querySelectorAll(".queuestatus")[0].innerHTML = "Uploaded! <a href='/uploads/'>Show uploads list</a>"
    // this is just a hack, but I like it actually.
    window.location.href = "/uploads/"
  });

  // Setup the buttons for all transfers
  // The "add files" button doesn't need to be setup because the config
  // `clickable` has already been specified.
  document.querySelector("#actions .start").onclick = function() {
    myDropzone.enqueueFiles(myDropzone.getFilesWithStatus(Dropzone.ADDED));
  };
  document.querySelector("#actions .cancel").onclick = function() {
    myDropzone.removeAllFiles(true);
  };
