FactoryBot.define do
  factory :oauth_application, class: 'Doorkeeper::Application' do
    name { "Test App" }
    redirect_uri { "https://example.com/callback" }
    scopes { "read write" }
  end
end
