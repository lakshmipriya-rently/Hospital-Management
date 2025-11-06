class PatientMailer < ApplicationMailer
  def patient_reminder(patient, appointment)
    @patient = patient
    @appointment = appointment
    mail(to: @patient&.user&.email, subject: "Upcoming Appointment Reminder")
  end
end
