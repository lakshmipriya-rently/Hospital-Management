# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
   before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  
  def new
    build_resource({})
    @doctor = Doctor.new
    @doctor.build_available
    @doctor.specializations.build
    @patient = Patient.new
    respond_with resource
  end

  # POST /resource
  
  def create
    build_resource(sign_up_params.except(:userable_attributes))
    case params[:user][:userable_type]
    when "Doctor"
      resource.userable = Doctor.new(doctor_params)
    when "Patient"
      resource.userable = Patient.new(patient_params)
    end

    resource.save
    yield resource if block_given?
    if resource.persisted?
      UserMailer.welcome_email(resource).deliver_now
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.

   def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
                                                  :name, :phone_no, :dob, :gender, :userable_type,
                                                  :password,:password_confirmation,
                                                  userable_attributes: [
                                                    :license_id, :experience, :type_of_degree, :salary,
                                                    :blood_group, :organ_donor, :address,
                                                    { specialization_ids: [] },
                                                    { available_attributes: [:start_time, :end_time, :is_active, { available_days: [] }] },
                                                  ],
                                                ])
   end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #    case resource.userable_type
  #    when "Doctor"
  #    new_doctor_path(user_id: resource.id)
  #    when "Patient"
  #    new_patient_path(user_id: resource.id)
  #    when "Staff"
  #    new_staff_path(user_id: resource.id)
  #    else
  #    root_path
  #    end
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end


  def patient_params
    params.require(:user).require(:userable_attributes).permit(
      :blood_group, :organ_donor, :address
    )
  end

  def doctor_params
    params.require(:user).require(:userable_attributes).permit(
      :license_id, :experience, :type_of_degree, :salary,
      { specialization_ids: [] },
      { available_attributes: [:start_time, :end_time, :is_active, { available_days: [] }] }
    )
  end
end
