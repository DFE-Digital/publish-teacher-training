# frozen_string_literal: true

require "rails_helper"

describe Support::SchoolForm, type: :model do
  subject { described_class.new(provider, location, params:) }

  let(:provider) { create(:provider) }
  let(:location) { provider.sites.build }
  let(:params) do
    {
      location_name: "The location",
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

    context "with missing address1" do
      it "is invalid" do
        params["address1"] = ""
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ address1: ["Enter address line 1"] })
      end
    end

    context "with missing town" do
      it "is invalid" do
        params["town"] = ""
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ town: ["Enter a town or city"] })
      end
    end

    context "with missing postcode" do
      it "is invalid" do
        params["postcode"] = ""
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ["Enter a postcode", "Enter a real postcode"] })
      end
    end

    context "with invalid postcodes" do
      it "is invalid" do
        params["postcode"] = "tr1"
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })

        params["postcode"] = "tr11"
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })

        params["postcode"] = "tr11u"
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })
      end
    end

    context "with valid postcode" do
      it "is valid" do
        params["postcode"] = "tr11un"
        expect(subject).to be_valid
      end
    end

    context "with invalid urns" do
      it "is invalid" do
        params["urn"] = "123"
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ urn: ["URN must be 5 or 6 numbers"] })

        params["urn"] = "qwert"
        expect(subject).not_to be_valid
        expect(subject.errors.messages).to eq({ urn: ["URN must be 5 or 6 numbers"] })
      end
    end

    context "with valid urn" do
      it "is valid" do
        params["urn"] = "12345"
        expect(subject).to be_valid
      end
    end

    describe "urn uniqueness" do
      context "when URN is blank" do
        before { params[:urn] = "" }

        it "is valid (no uniqueness check for blank URN)" do
          expect(subject).to be_valid
        end
      end

      context "when URN is nil" do
        before { params[:urn] = nil }

        it "is valid (no uniqueness check for nil URN)" do
          expect(subject).to be_valid
        end
      end

      context "when another school site has the same URN" do
        let!(:existing_site) do
          create(:site, provider:, urn: "123456", site_type: :school)
        end

        before do
          params[:urn] = "123456"
        end

        it "is invalid" do
          expect(subject).not_to be_valid
          expect(subject.errors[:urn]).to include("URN is in use by another location")
        end
      end

      context "when a study site has the same URN" do
        let!(:existing_study_site) do
          create(:site, provider:, urn: "123456", site_type: :study_site)
        end

        context "and the new site is a school" do
          before do
            params[:urn] = "123456"
            params[:site_type] = :school
          end

          it "is valid (schools and study sites have separate namespaces)" do
            expect(subject).to be_valid
          end
        end
      end

      context "when the same site is being updated" do
        let(:existing_site) do
          create(:site, provider:, urn: "123456", site_type: :school)
        end
        let(:location) { existing_site }

        before do
          params[:urn] = "123456"
          params[:location_name] = "Updated Name"
        end

        it "is valid (same site can keep its own URN)" do
          expect(subject).to be_valid
        end
      end

      context "when a site from a different provider has the same URN" do
        let(:other_provider) { create(:provider) }
        let!(:other_site) do
          create(:site, provider: other_provider, urn: "123456")
        end

        before { params[:urn] = "123456" }

        it "is valid (URN only needs to be unique within provider)" do
          expect(subject).to be_valid
        end
      end

      context "when editing a study site" do
        let!(:existing_study_site) do
          create(:site, provider:, urn: "111111", site_type: :study_site)
        end
        let!(:another_study_site) do
          create(:site, provider:, urn: "123456", site_type: :study_site)
        end
        let(:location) { provider.study_sites.build(site_type: :study_site) }

        before { params[:urn] = "123456" }

        it "is invalid when duplicating another study site URN" do
          expect(subject).not_to be_valid
          expect(subject.errors[:urn]).to include("URN is in use by another location")
        end
      end

      context "when multiple sites have blank URNs" do
        let!(:site_without_urn_1) do
          create(:site, provider:, urn: nil, site_type: :school)
        end
        let!(:site_without_urn_2) do
          create(:site, provider:, urn: "", site_type: :school)
        end

        before { params[:urn] = nil }

        it "is valid (multiple sites can have blank URNs)" do
          expect(subject).to be_valid
        end
      end

      context "when URN has both format and uniqueness errors" do
        let!(:existing_site) do
          create(:site, provider:, urn: "123456", site_type: :school)
        end

        before { params[:urn] = "12345" }

        it "is valid (different URN despite format being valid)" do
          expect(subject).to be_valid
        end
      end

      context "when URN is duplicate and has validation error" do
        let!(:existing_site) do
          create(:site, provider:, urn: "123456", site_type: :school)
        end

        before { params[:urn] = "123456" }

        it "shows uniqueness error" do
          expect(subject).not_to be_valid
          expect(subject.errors[:urn]).to include("URN is in use by another location")
          expect(subject.errors[:urn]).not_to include("URN must be 5 or 6 numbers")
        end
      end
    end
  end

  describe "save!" do
    context "valid form" do
      it "updates the provider location with the new details" do
        expect { subject.save! }
          .to change(location, :location_name).to("The location")
          .and change(location, :address1).to("My street")
          .and change(location, :town).to("My town")
          .and change(location, :postcode).to("TR1 1UN")
      end
    end

    context "invalid form" do
      let(:params) { { postcode: "tr1", location_name: "Another site", address1: "Another street" } }

      it "does not update the provider location with invalid details" do
        expect { subject.save! }.not_to(change(location, :postcode))
        expect { subject.save! }.not_to(change(location, :location_name))
        expect { subject.save! }.not_to(change(location, :address1))
        expect { subject.save! }.not_to(change(location, :town))
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
