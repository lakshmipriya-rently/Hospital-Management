namespace :record_count do
  desc "Display the count of doctors"
  task doctors_count: :environment do
    puts "Doctors count: #{Doctor.count}"
  end

  desc "Display the count of patients"
  task patients_count: :environment do
    puts "Patients count: #{Patient.count}"
  end

  desc "Display the count of appointments"
  task appointments_count: :environment do
    puts "Appointments count: #{Appointment.count}"
  end

  desc "Display the count of surgeries"
  task surgeries_count: :environment do
    puts "Surgeries count: #{Surgery.count}"
  end
end
