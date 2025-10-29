import { Application } from "@hotwired/stimulus"
import { definitionsFromContext } from "@hotwired/stimulus-webpack-helpers"

import toastr from "toastr"
import "toastr/build/toastr.min.css"

// expose toastr to the global window so Stimulus controllers can use it
window.toastr = toastr

const application = Application.start()
const context = require.context(".", true, /\.js$/)
application.load(definitionsFromContext(context))
