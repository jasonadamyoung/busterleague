/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//

var jQuery = require('jquery')
// include jQuery in global and window scope (so you can access it globally)
// in your web browser, when you type $('.div'), it is actually refering to global.$('.div')
global.$ = global.jQuery = jQuery;
window.$ = window.jQuery = jQuery;

require("@rails/ujs").start()
import 'bootstrap';
import "../stylesheets/application"
import "@fortawesome/fontawesome-free/js/all"
import "controllers"
import "core-js/stable"
import "regenerator-runtime/runtime"
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)
require('datatables.net-bs4')

// custom
// require("custom/cable")
// require("custom/activate_editable")
// require("custom/datatables")
require("custom/draftplayersearch")
require("custom/js_cookie")
require("custom/players")
require("custom/searchbox")
require("custom/tables")
require("custom/uploads")


// import "spectrum-colorpicker2/dist/spectrum"

$(function () {
  console.log('Hello World from Webpacker');
});
