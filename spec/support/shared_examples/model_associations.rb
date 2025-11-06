RSpec.shared_examples "has association" do |association_name, type|
  it "has #{type} #{association_name}" do
    association = described_class.reflect_on_association(association_name)
    expect(association.macro).to eq type
  end
end
