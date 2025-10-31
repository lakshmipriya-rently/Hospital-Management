require 'rails_helper'

RSpec.describe 'Api::V1::Surgeries', type: :request do
  let(:doctor_user) { create(:user, :doctor) }
  let(:patient_user) { create(:user, :patient) }

  let(:doctor_token) { create(:doorkeeper_access_token, resource_owner_id: doctor_user.id, scopes: 'public') }
  let(:patient_token) { create(:doorkeeper_access_token, resource_owner_id: patient_user.id, scopes: 'public') }

  let(:headers_doctor) do
    { 'Authorization' => "Bearer #{doctor_token.token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  let(:headers_patient) do
    { 'Authorization' => "Bearer #{patient_token.token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
  end

  def json_response
    JSON.parse(response.body)
  end

  describe 'GET /api/v1/surgeries/:id' do
    it 'returns correct JSON message when surgery not found' do
      get '/api/v1/surgeries/999999', headers: headers_doctor
      expect(response).to have_http_status(:not_found)
      expect(json_response['error']).to eq('Surgery not found')
    end
  end

  describe 'GET /api/v1/surgeries' do
    it 'returns all surgeries' do
      create_list(:surgery, 2, doctor: doctor_user.userable)
      get '/api/v1/surgeries', headers: headers_doctor
      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(Surgery.count)
    end
  end

  describe 'GET /api/v1/surgeries/:id (exists)' do
    it 'returns surgery JSON when found' do
      s = create(:surgery, doctor: doctor_user.userable)
      get "/api/v1/surgeries/#{s.id}", headers: headers_doctor
      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(s.id)
    end
  end

  describe 'POST /api/v1/surgeries' do
    context 'when doctor creates with invalid params' do
      let(:invalid_params) { { surgery: { name: '', description: '' } } }

      it 'does not create a surgery and returns unprocessable_entity' do
        expect {
            post '/api/v1/surgeries', params: invalid_params.to_json, headers: headers_doctor
          }.not_to change(Surgery, :count)
          expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'renders JSON errors for invalid surgery' do
  post '/api/v1/surgeries', params: invalid_params.to_json, headers: headers_doctor
        parsed = json_response
        expect(parsed).to include('errors')
      end
    end

    context 'when doctor creates with valid params' do
      let(:valid_params) { { surgery: { name: 'Appendectomy', description: 'Removal of appendix' } } }

      it 'creates a surgery and returns created' do
        expect {
          post '/api/v1/surgeries', params: valid_params.to_json, headers: headers_doctor
        }.to change(Surgery, :count).by(1)
        expect(response).to have_http_status(:created)
        parsed = json_response
        expect(parsed['name']).to eq('Appendectomy')
      end
    end

    context 'when non-doctor attempts to create' do
      let(:valid_params) { { surgery: { name: 'Appendectomy', description: 'Removal of appendix' } } }

      it 'returns forbidden' do
        post '/api/v1/surgeries', params: valid_params.to_json, headers: headers_patient
        expect(response).to have_http_status(:forbidden)
        parsed = json_response
        expect(parsed['error']).to be_present
      end
    end
  end

  describe 'POST /api/v1/surgeries/:id/book_appointment' do
    let!(:surgery) { create(:surgery, doctor: doctor_user.userable) }

    context 'when current user is not a patient' do
      it 'returns forbidden with proper message' do
        post "/api/v1/surgeries/#{surgery.id}/book_appointment", headers: headers_doctor
        expect(response).to have_http_status(:forbidden)
        parsed = json_response
        expect(parsed['error']).to eq('You must be logged in as a patient to book an appointment.')
      end
    end

    context 'when patient books' do
      it 'returns created (placeholder) message' do
        post "/api/v1/surgeries/#{surgery.id}/book_appointment", headers: headers_patient
        expect(response).to have_http_status(:created)
        expect(json_response['message']).to eq('Appointment booked')
      end
    end
  end

  describe 'DELETE /api/v1/surgeries/:id' do
    context 'when doctor owns the surgery' do
      it 'destroys the surgery and returns no_content' do
        s = create(:surgery, doctor: doctor_user.userable)
        expect {
          delete "/api/v1/surgeries/#{s.id}", headers: headers_doctor
        }.to change(Surgery, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when doctor does not own the surgery' do
      it 'returns forbidden' do
        other_doc = create(:user, :doctor)
        other_token = create(:doorkeeper_access_token, resource_owner_id: other_doc.id, scopes: 'public')
        other_headers = { 'Authorization' => "Bearer #{other_token.token}", 'Content-Type' => 'application/json', 'Accept' => 'application/json' }
        s = create(:surgery, doctor: doctor_user.userable)
        delete "/api/v1/surgeries/#{s.id}", headers: other_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
