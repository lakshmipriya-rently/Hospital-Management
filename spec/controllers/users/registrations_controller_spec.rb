require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  render_views

  include Devise::Test::ControllerHelpers

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'GET #new' do
    before { get :new }

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'builds doctor and patient instances for the view' do
      expect(assigns(:doctor)).to be_a_new(Doctor)
      expect(assigns(:patient)).to be_a_new(Patient)
    end
  end

  describe 'POST #create' do
    let(:user_attrs) { attributes_for(:user) }

    before do
      allow(UserMailer).to receive(:welcome_email).and_return(double(deliver_now: true))
    end

    context 'when signing up as a Doctor' do
      let(:doctor_params) do
        {
          user: {
            name: user_attrs[:name],
            email: "doc+#{SecureRandom.hex(4)}@example.com",
            password: 'password123',
            password_confirmation: 'password123',
            phone_no: '9876543210',
            dob: 20.years.ago.to_date,
            userable_type: 'Doctor',
            userable_attributes: {
              license_id: 'LIC123',
              experience: 5,
              type_of_degree: 'MBBS',
            }
          }
        }
      end

      it 'creates a new User with a Doctor userable and redirects' do
        expect { post :create, params: doctor_params }.to change(User, :count).by(1)
        user = User.last
     expect(user.userable).to be_a(Doctor)
     expect(response).to be_redirect
      end
    end

    context 'when signing up as a Patient' do
      let(:patient_params) do
        {
          user: {
            name: user_attrs[:name],
            email: "pat+#{SecureRandom.hex(4)}@example.com",
            password: 'password123',
            password_confirmation: 'password123',
            phone_no: '9123456780',
            dob: 25.years.ago.to_date,
            userable_type: 'Patient',
            userable_attributes: {
              blood_group: 'O+',
              address: '123 Main St'
            }
          }
        }
      end

      it 'creates a new User with a Patient userable and redirects' do
        expect { post :create, params: patient_params }.to change(User, :count).by(1)
        user = User.last
  expect(user.userable).to be_a(Patient)
  expect(response).to be_redirect
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        { user: { email: '', password: '', password_confirmation: '' } }
      end

      it 'does not create a user and returns unprocessable entity or renders new' do
        expect { post :create, params: invalid_params }.not_to change(User, :count)
        expect([200, 422]).to include(response.status)
      end
    end
  end
end
