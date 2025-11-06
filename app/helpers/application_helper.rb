module ApplicationHelper
  def toastr_flash
    flash_messages = []
    flash.each do |type, message|
      toastr_type = case type.to_s
      when "notice" then "success"
      when "alert" then "error"
      when "error", "success", "warning", "info" then type.to_s
      else "info"
      end
      Array(message).each do |msg|
        next if msg.blank?

        html = content_tag(:div, nil,
                           data: {
                             controller: "toastr",
                             "toastr-type": toastr_type,
                             "toastr-message": ERB::Util.html_escape(msg)
                           })
        flash_messages << html
      end
    end
    safe_join(flash_messages, "\n")
  end
end
