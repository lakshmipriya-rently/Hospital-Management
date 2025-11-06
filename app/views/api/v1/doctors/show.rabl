object @doctor
extends "api/v1/doctors/_doctor"

child :user do
 attributes :name, :gender, :email, :dob, :age
end
