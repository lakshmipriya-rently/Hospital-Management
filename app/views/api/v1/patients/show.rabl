object @patient
extends "api/v1/patients/_patient"

child :user do
 attributes :name,:gender,:email,:dob,:age
end
