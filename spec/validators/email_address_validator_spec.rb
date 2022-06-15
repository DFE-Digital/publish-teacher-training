require "rails_helper"

describe EmailAddressValidator do
  let(:model) do
    Class.new do
      include ActiveRecord::Validations

      attr_accessor :email

      validates :email, email_address: true
    end
  end

  let(:instance) { model.new }

  before do
    instance.validate(:no_context)
    instance.email = email_string
  end

  subject { instance.valid?(:no_context) }

  shared_examples "an invalid email address" do |value|
    let(:email_string) { value }

    it { is_expected.to be_falsey }

    it "returns the correct error message" do
      expect(instance.errors[:email]).to(include("Enter an email address in the correct format, like name@example.com"))
    end
  end

  it_behaves_like "an invalid email address", nil
  it_behaves_like "an invalid email address", " "
  it_behaves_like "an invalid email address", "cats4lyf"
  it_behaves_like "an invalid email address", "cats4lyf@meow.cat or dogs4evar@bork.dog"
  it_behaves_like "an invalid email address", "cats@meow. cat"
  it_behaves_like "an invalid email address", "cats@meow.cat "

  describe "with a valid email address" do
    let(:email_string) { "cats@meow.cat" }

    it { is_expected.to be_truthy }
  end
end
