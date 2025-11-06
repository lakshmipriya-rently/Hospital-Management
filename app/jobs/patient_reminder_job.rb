
class PatientReminderJob < ApplicationJob
  queue_as :mailers

  def perform(appointment_id)
    confirmed_appointment = Appointment.find_by(id: appointment_id)
    return unless confirmed_appointment&.status == "pending"

    patient = confirmed_appointment&.patient
    doctor = confirmed_appointment&.doctor

    PatientMailer.patient_reminder(confirmed_appointment&.patient, confirmed_appointment).deliver_later
  end
end
