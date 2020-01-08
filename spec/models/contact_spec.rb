# == Schema Information
#
# Table name: contact
#
#  created_at  :datetime         not null
#  email       :text
#  id          :bigint           not null, primary key
#  name        :text
#  provider_id :integer          not null
#  telephone   :text
#  type        :text             not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_contact_on_provider_id           (provider_id)
#  index_contact_on_provider_id_and_type  (provider_id,type) UNIQUE
#

require "rails_helper"

describe Contact, type: :model do
  it { should belong_to(:provider) }

  describe "type" do
    it "is an enum" do
      expect(subject)
        .to define_enum_for(:type)
              .backed_by_column_of_type(:text)
              .with_values(
                admin: "admin",
                utt: "utt",
                web_link: "web_link",
                fraud: "fraud",
                finance: "finance",
              )
              .with_suffix("contact")
    end
  end

  describe "on update" do
    let(:provider) { create(:provider, contacts: contacts, changed_at: 5.minutes.ago) }
    let(:contacts) { [build(:contact)] }
    let(:contact) { contacts.first }

    before do
      provider
    end

    it "should touch the provider" do
      contacts.first.save
      expect(provider.reload.changed_at).to be_within(1.second).of Time.now.utc
    end


    it { should validate_presence_of(:name) }

    describe "telephone" do
      it "validates telephone is present" do
        contact.telephone = ""
        contact.valid?

        expect(contact.errors[:telephone]).to include("^Enter a valid telephone number")
      end

      it "Correctly validates valid phone numbers" do
        contact.telephone = "+447 123 123 123"
        expect(contact.valid?).to be true
      end

      it "Correctly invalidates invalid phone numbers" do
        contact.telephone = "123foo456"
        expect(contact.valid?).to be false
        expect(contact.errors[:telephone]).to include("^Enter a valid telephone number")
      end
    end

    describe "email" do
      it "validates email is present" do
        contact.email = ""
        contact.valid?

        expect(contact.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
      end

      it "validates email contains an @ symbol" do
        contact.email = "bar"
        contact.valid?

        expect(contact.errors[:email]).to include("^Enter an email address in the correct format, like name@example.com")
      end

      it "Does not validate the email if it is present"do
        contact.email = "foo@bar.com"

        expect(contact.valid?).to be true
      end
    end
  end
end
