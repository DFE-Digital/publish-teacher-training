# frozen_string_literal: true

require "rails_helper"

describe Support::UserForm, type: :model do
  let(:user) { create(:user) }
  let(:model) { create(:user) }
  let(:user_store) { double(UserStore) }
  let(:params) { { email: "foo@bar.com", first_name: "Foo", last_name: "Bar" } }

  subject { described_class.new(user, model, params:) }

  before do
    allow(user_store).to receive(:get).and_return(nil)
  end

  describe "validations" do
    before { subject.validate }

    context "blank first_name" do
      let(:params) { { first_name: nil } }

      it "is invalid" do
        expect(subject.errors[:first_name]).to include("Enter a first name")
        expect(subject.valid?).to be(false)
      end
    end

    context "blank last_name" do
      let(:params) { { last_name: nil } }

      it "is invalid" do
        expect(subject.errors[:last_name]).to include("Enter a last name")
        expect(subject.valid?).to be(false)
      end
    end

    context "blank email" do
      let(:params) { { email: nil } }

      it "is invalid" do
        expect(subject.errors[:email]).to include("Enter an email address in the correct format, like name@example.com")
        expect(subject.valid?).to be(false)
      end
    end

    context "uppercase email" do
      let(:params) { { email: "FOOBAR@BAT.COM" } }

      it "is invalid" do
        expect(subject.errors[:email]).to include("Enter an email address that is lowercase, like name@example.com")
        expect(subject.valid?).to be(false)
      end
    end

    context "valid params" do
      it "is valid" do
        expect(subject.valid?).to be(true)
      end
    end
  end

  describe "save!" do
    context "valid form" do
      it "updates the provider user with the new details" do
        expect { subject.save! }
        .to change { model.first_name }.to("Foo")
        .and change { model.last_name }.to("Bar")
        .and change { model.email }.to("foo@bar.com")
      end
    end

    context "invalid email" do
      let(:params) { { email: "invalid email", first_name: "Foo", last_name: "Bar" } }

      it "does not update the provider user with invalid details" do
        expect { subject.save! }
        .not_to(change { model.email })
      end
    end

    context "blank first name" do
      let(:params) { { email: "foo@bar.com", first_name: "", last_name: "Bar" } }

      it "does not update the provider user with invalid details" do
        expect { subject.save! }
        .not_to(change { model.first_name })
      end
    end

    context "blank last name" do
      let(:params) { { email: "foo@bar.com", first_name: "Foo", last_name: "" } }

      it "does not update the provider user with invalid details" do
        expect { subject.save! }
        .not_to(change { model.last_name })
      end
    end
  end

  describe "#stash" do
    context "valid details" do
      it "returns true" do
        expect(subject.stash).to be true
        expect(subject.errors.messages).to be_blank
      end
    end

    context "missing last name" do
      let(:params) { { email: "foo@bar.com", first_name: "Foo", last_name: "" } }

      it "returns nil" do
        expect(subject.stash).to be_nil
        expect(subject.errors.messages).to eq({ last_name: ["Enter a last name"] })
      end
    end

    context "missing first name" do
      let(:params) { { email: "foo@bar.com", first_name: "", last_name: "Bar" } }

      it "returns nil" do
        expect(subject.stash).to be_nil
        expect(subject.errors.messages).to eq({ first_name: ["Enter a first name"] })
      end
    end

    context "missing email" do
      let(:params) { { email: "", first_name: "Foo", last_name: "Bar" } }

      it "returns nil" do
        expect(subject.stash).to be_nil
        expect(subject.errors.messages).to eq({ email: ["Enter an email address", "Enter an email address in the correct format, like name@example.com"] })
      end
    end
  end
end
