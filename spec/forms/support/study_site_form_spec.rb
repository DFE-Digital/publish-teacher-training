# frozen_string_literal: true

require "rails_helper"

describe Support::StudySiteForm, type: :model do
  subject { described_class.new(provider, site, params:) }

  let(:provider) { create(:provider) }
  let(:site) { provider.study_sites.build(site_type: :study_site) }
  let(:params) do
    {
      location_name: "The study site",
      address1: "My street",
      town: "My town",
      postcode: "TR1 1UN",
    }
  end

  describe "validations" do
    it { is_expected.to be_valid }

    context "with missing location_name" do
      it "is invalid" do
        params["location_name"] = ""
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ location_name: ["Enter a name"] })
      end
    end

    context "with existing provider.study_sites location_name" do
      let!(:study_site1) { create(:site, provider:, location_name: "Hogwarts Study Site", site_type: :study_site) }
      let(:params) do
        {
          location_name: study_site1.location_name,
          address1: "My street",
          town: "My town",
          postcode: "TR1 1UN",
        }
      end

      it "is invalid" do
        expect(subject).not_to be_valid
        expect(subject.errors[:location_name]).to include("Name is taken")
      end
    end

    context "when a school has the same name" do
      let!(:existing_school) do
        create(:site, provider:, location_name: "Same Name", site_type: :school)
      end
      let(:params) do
        {
          location_name: "Same Name",
          address1: "My street",
          town: "My town",
          postcode: "TR1 1UN",
        }
      end

      it "is valid (schools and study sites have separate namespaces)" do
        expect(subject).to be_valid
      end
    end

    include_examples "study site urn uniqueness validation"
  end

  describe "save!" do
    context "valid form" do
      it "updates the provider location with the new details" do
        expect { subject.save! }
          .to change(site, :location_name).to("The study site")
          .and change(site, :address1).to("My street")
          .and change(site, :town).to("My town")
          .and change(site, :postcode).to("TR1 1UN")
      end
    end

    context "invalid form" do
      let(:params) { { postcode: "tr1", location_name: "Another site", address1: "Another street" } }

      it "does not update the provider location with invalid details" do
        expect { subject.save! }.not_to(change(site, :postcode))
        expect { subject.save! }.not_to(change(site, :location_name))
        expect { subject.save! }.not_to(change(site, :address1))
        expect { subject.save! }.not_to(change(site, :town))
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

    context "missing required attribute" do
      let(:params) do
        {
          location_name: "",
          address1: "My street",
          town: "My town",
          postcode: "TR1 1UN",
        }
      end

      it "returns nil" do
        expect(subject.stash).to be_nil
        expect(subject.errors.messages).to eq({ location_name: ["Enter a name"] })
      end
    end
  end
end
