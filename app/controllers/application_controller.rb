class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
   allow_browser versions: :modern
   before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
  devise_parameter_sanitizer.permit(:sign_up, keys: [
  :name, :phone_no, :dob, :gender, :userable_type,
  userable_attributes: [
    :license_id, :experience, :type_of_degree, :salary,
    :blood_group, :organ_donor, :address,
    { specialization_ids: [] },
    { available_attributes: [:start_time, :end_time, :is_active, { available_days: [] }] }
  ]
])

devise_parameter_sanitizer.permit(:account_update, keys: [
  :name, :phone_no, :dob, :gender, :userable_type,
  userable_attributes: [
    :license_id, :experience, :type_of_degree, :salary,
    :blood_group, :organ_donor, :address,
    { specialization_ids: [] },
    { available_attributes: [:start_time, :end_time, :is_active, { available_days: [] }] }
  ]
])
  end
end
