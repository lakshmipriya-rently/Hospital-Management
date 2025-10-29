// app/javascript/application.js

import "@hotwired/turbo-rails"
import "controllers"

// Make jQuery globally available
import "jquery"
window.$ = window.jQuery = jQuery

// Import toastr from CDN (pinned in importmap.rb)
import "toastr"

// Optional global toastr config
window.toastr.options = {
  closeButton: true,
  progressBar: true,
  positionClass: "toast-top-right",
  timeOut: "4000"
}
