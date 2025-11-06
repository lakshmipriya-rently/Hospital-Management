require 'rails_helper'

RSpec.describe Surgery, type: :model do
  describe 'associations' do
    it_behaves_like "has association", :patients, :has_many
    it_behaves_like "has association", :appointments, :has_many
    it_behaves_like "has association", :doctor, :belongs_to
  end
end
