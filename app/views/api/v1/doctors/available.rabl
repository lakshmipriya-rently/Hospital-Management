object @doctor
extends "api/v1/doctors/_doctor"

child :available do
  attributes :start_time, :end_time, :available_days
end
