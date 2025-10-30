# frozen_string_literal: true

require "rails_helper"

module Publish
  describe StudySiteForm, type: :model do
    subject { described_class.new(site, params:) }

    let(:provider) { create(:provider) }
    let(:site) { provider.study_sites.build(site_type: :study_site) }
    let(:params) do
      {
        location_name: "Test Study Site",
        address1: "123 Main Street",
        address2: "Building A",
        address3: "Floor 2",
        town: "London",
        address4: "Greater London",
        postcode: "SW1A 1AA",
        urn: "123456",
        site_type: "study_site",
      }
    end

    describe "validations" do
      it { is_expected.to be_valid }

      describe "location_name" do
        context "when missing" do
          before { params[:location_name] = "" }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ location_name: ["Enter a name"] })
          end
        end
      end

      describe "location_name uniqueness" do
        context "when another study site has the same name" do
          let!(:existing_site) do
            create(:site, provider:, location_name: "Duplicate Study Site", site_type: :study_site)
          end

          before { params[:location_name] = "Duplicate Study Site" }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:location_name]).to include("This study site has already been added")
          end
        end

        context "when a school has the same name" do
          let!(:existing_school) do
            create(:site, provider:, location_name: "Duplicate Location", site_type: :school)
          end

          before do
            params[:location_name] = "Duplicate Location"
          end

          it "is valid (schools and study sites have separate namespaces)" do
            expect(subject).to be_valid
          end
        end

        context "when the same site is being updated" do
          let(:existing_site) do
            create(:site, provider:, location_name: "Existing Study Site", site_type: :study_site)
          end
          let(:site) { existing_site }

          before { params[:location_name] = "Existing Study Site" }

          it "is valid (same site can keep its own name)" do
            expect(subject).to be_valid
          end
        end

        context "when a site from a different provider has the same name" do
          let(:other_provider) { create(:provider) }
          let!(:other_site) do
            create(:site, provider: other_provider, location_name: "Same Name Study Site", site_type: :study_site)
          end

          before { params[:location_name] = "Same Name Study Site" }

          it "is valid (name only needs to be unique within provider)" do
            expect(subject).to be_valid
          end
        end
      end

      include_examples "study site urn uniqueness validation"
    end

    describe "#save!" do
      context "with valid form" do
        it "saves the site with all provided fields" do
          expect { subject.save! }
            .to change(site, :persisted?).from(false).to(true)
            .and change(site, :location_name).to("Test Study Site")
            .and change(site, :address1).to("123 Main Street")
        end

        it "returns true" do
          expect(subject.save!).to be_truthy
        end
      end

      context "with invalid form" do
        before { params[:location_name] = "" }

        it "does not save the site" do
          expect { subject.save! }.not_to(change(site, :persisted?))
        end

        it "returns false" do
          expect(subject.save!).to be false
        end
      end
    end
  end
end
