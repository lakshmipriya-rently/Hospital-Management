require 'rails_helper'

RSpec.describe Users::RegistrationsController, type: :controller do
  render_views

  include Devise::Test::ControllerHelpers

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end


  describe 'GET #new' do
    before { get :new }

    it 'responds successfully' do
      expect(response).to have_http_status(:ok)
    end

    it 'builds doctor instances for the view' do
      expect(assigns(:doctor)).to be_a_new(Doctor)
    end

    it 'builds patient instances for the view' do
      expect(assigns(:patient)).to be_a_new(Patient)
    end
  end

  describe 'POST #create' do
    let(:user_attrs) { attributes_for(:user) }

    before do
    allow(UserMailer).to receive(:welcome_email)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))
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
              type_of_degree: 'MBBS'
            }
          }
        }
      end

      it 'creates a new User with a Doctor userable' do
        post :create, params: doctor_params
        user = User.last
        expect(user.userable).to be_a(Doctor)
      end

       it 'creates a new User with a Doctor userable and redirects' do
        post :create, params: doctor_params
        user = User.last
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

      it 'creates a new User with a Patient userable' do
        post :create, params: patient_params
        user = User.last
        expect(user.userable).to be_a(Patient)
      end

       it 'creates a new User with a Patient userable and redirects' do
        post :create, params: patient_params
        user = User.last
        expect(response).to be_redirect
      end
    end

    context 'when user is created but inactive' do
  let(:inactive_params) do
    {
      user: {
        name: "Inactive User",
        email: "inactive+#{SecureRandom.hex(4)}@example.com",
        password: "password123",
        password_confirmation: "password123",
        phone_no: "9876543211",
        dob: 20.years.ago.to_date,
        userable_type: "Patient",
        userable_attributes: {
          blood_group: "B+",
          address: "Inactive Street"
        }
      }
    }
  end

  it 'renders the inactive signup flow' do
    allow_any_instance_of(User).to receive(:active_for_authentication?).and_return(false)
    allow(UserMailer).to receive(:welcome_email)
      .and_return(instance_double(ActionMailer::MessageDelivery, deliver_now: true))
    post :create, params: inactive_params
    expect(flash[:notice]).to include("You have signed up successfully. However, we could not sign you in because your account is not yet activated.")
  end
end


    context 'with invalid params' do
      let(:invalid_params) do
        { user: { email: '', password: '', password_confirmation: '' } }
      end

      it 'does not create a user and returns unprocessable entity or renders new' do
         post :create, params: invalid_params
         expect(response.status).to be_in([ 200, 422 ])
      end
    end
  end
end
