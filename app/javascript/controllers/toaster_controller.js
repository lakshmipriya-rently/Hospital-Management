import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const toastr = window.toastr
    if (!toastr) {
      console.warn("⚠️ toastr not found on window. Check your importmap setup.")
      return
    }

    let type = this.data.get("toastrType") || "success"
    const message = this.data.get("toastrMessage")

    const validTypes = ["success", "info", "warning", "error"]
    if (!validTypes.includes(type)) {
      type = "info"
    }

    if (message) {
      toastr.options = {
        closeButton: true,
        progressBar: true,
        positionClass: "toast-top-right",
        timeOut: 4000
      }
      toastr[type](message)
    }

    console.log("✅ Toastr controller connected!")
  }
}
