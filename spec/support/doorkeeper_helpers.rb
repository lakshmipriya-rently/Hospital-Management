RSpec.configure do |config|
  
  config.before(:each, type: :request) do
    allow_any_instance_of(Api::V1::BaseController).to receive(:doorkeeper_authorize!) do |controller, *args|

      auth = controller.request.headers['Authorization'] || controller.request.headers['HTTP_AUTHORIZATION']
      if auth.present? && auth.start_with?('Bearer ')
        token = auth.split(' ').last
        access_token = Doorkeeper::AccessToken.find_by(token: token)
        user = User.find_by(id: access_token&.resource_owner_id)
        allow(controller).to receive(:current_user_api).and_return(user)
      else
        allow(controller).to receive(:current_user_api).and_return(nil)
      end
      true
    end
  end
end
