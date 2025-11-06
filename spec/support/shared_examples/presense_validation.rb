RSpec.shared_examples "presence validation" do |attribute|
  it "validates presence of #{attribute}" do
    subject.validate
    expect(subject.errors[attribute]).to include("can't be blank")
  end
end
