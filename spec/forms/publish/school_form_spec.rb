# frozen_string_literal: true

require "rails_helper"

module Publish
  describe SchoolForm, type: :model do
    subject { described_class.new(site, params:) }

    let(:provider) { create(:provider) }
    let(:site) { provider.sites.build }
    let(:params) do
      {
        location_name: "Test School",
        address1: "123 Main Street",
        address2: "Building A",
        address3: "Floor 2",
        town: "London",
        address4: "Greater London",
        postcode: "SW1A 1AA",
        urn: "123456",
        site_type: "school",
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

        context "when nil" do
          before { params[:location_name] = nil }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:location_name]).to include("Enter a name")
          end
        end
      end

      describe "address1" do
        context "when missing" do
          before { params[:address1] = "" }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ address1: ["Enter address line 1"] })
          end
        end

        context "when nil" do
          before { params[:address1] = nil }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:address1]).to include("Enter address line 1")
          end
        end
      end

      describe "town" do
        context "when missing" do
          before { params[:town] = "" }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ town: ["Enter a town or city"] })
          end
        end

        context "when nil" do
          before { params[:town] = nil }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:town]).to include("Enter a town or city")
          end
        end
      end

      describe "postcode" do
        context "when missing" do
          before { params[:postcode] = "" }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ postcode: ["Enter a postcode", "Enter a real postcode"] })
          end
        end

        context "when nil" do
          before { params[:postcode] = nil }

          it "is invalid" do
            expect(subject).not_to be_valid
            expect(subject.errors[:postcode]).to include("Enter a postcode")
          end
        end

        context "with invalid format" do
          it "is invalid with incomplete postcode" do
            params[:postcode] = "sw1"
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })
          end

          it "is invalid with partial postcode" do
            params[:postcode] = "sw1a"
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })
          end

          it "is invalid with incomplete outward code" do
            params[:postcode] = "sw1a1"
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ postcode: ["Enter a real postcode"] })
          end

          it "is invalid with random string" do
            params[:postcode] = "invalid"
            expect(subject).not_to be_valid
            expect(subject.errors[:postcode]).to include("Enter a real postcode")
          end
        end

        context "with valid format" do
          it "is valid with standard format" do
            params[:postcode] = "SW1A 1AA"
            expect(subject).to be_valid
          end

          it "is valid with lowercase" do
            params[:postcode] = "sw1a 1aa"
            expect(subject).to be_valid
          end

          it "is valid without space" do
            params[:postcode] = "SW1A1AA"
            expect(subject).to be_valid
          end

          it "is valid with different format" do
            params[:postcode] = "M1 1AE"
            expect(subject).to be_valid
          end
        end
      end

      describe "urn" do
        context "when blank" do
          before { params[:urn] = "" }

          it "is valid (URN is optional)" do
            expect(subject).to be_valid
          end
        end

        context "when nil" do
          before { params[:urn] = nil }

          it "is valid (URN is optional)" do
            expect(subject).to be_valid
          end
        end

        context "with invalid format" do
          it "is invalid with too few digits" do
            params[:urn] = "123"
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ urn: ["URN must be 5 or 6 numbers"] })
          end

          it "is invalid with 4 digits" do
            params[:urn] = "1234"
            expect(subject).not_to be_valid
            expect(subject.errors[:urn]).to include("URN must be 5 or 6 numbers")
          end

          it "is invalid with too many digits" do
            params[:urn] = "1234567"
            expect(subject).not_to be_valid
            expect(subject.errors[:urn]).to include("URN must be 5 or 6 numbers")
          end

          it "is invalid with letters" do
            params[:urn] = "abcde"
            expect(subject).not_to be_valid
            expect(subject.errors.messages).to eq({ urn: ["URN must be 5 or 6 numbers"] })
          end

          it "is invalid with alphanumeric" do
            params[:urn] = "12a45"
            expect(subject).not_to be_valid
            expect(subject.errors[:urn]).to include("URN must be 5 or 6 numbers")
          end
        end

        context "with valid format" do
          it "is valid with 5 digits" do
            params[:urn] = "12345"
            expect(subject).to be_valid
          end

          it "is valid with 6 digits" do
            params[:urn] = "123456"
            expect(subject).to be_valid
          end
        end
      end

      include_examples "school urn uniqueness validation"

      describe "optional fields" do
        before do
          params[:address2] = nil
          params[:address3] = nil
          params[:address4] = nil
          params[:urn] = nil
        end

        it "is valid without optional fields" do
          expect(subject).to be_valid
        end
      end
    end

    describe "#save!" do
      context "with valid form" do
        it "saves the site with all provided fields" do
          expect { subject.save! }
            .to change(site, :persisted?).from(false).to(true)
            .and change(site, :location_name).to("Test School")
            .and change(site, :address1).to("123 Main Street")
            .and change(site, :address2).to("Building A")
            .and change(site, :address3).to("Floor 2")
            .and change(site, :town).to("London")
            .and change(site, :address4).to("Greater London")
            .and change(site, :postcode).to("SW1A 1AA")
            .and change(site, :urn).to("123456")
        end

        it "returns true" do
          expect(subject.save!).to be_truthy
        end

        it "normalizes postcode" do
          params[:postcode] = "sw1a1aa"
          subject.save!
          expect(site.postcode).to eq("SW1A 1AA")
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

        it "does not change site attributes" do
          expect { subject.save! }
            .not_to change(site, :location_name)
        end
      end

      context "when updating an existing site" do
        let(:site) do
          create(:site,
                 provider:,
                 location_name: "Old Name",
                 address1: "Old Street",
                 town: "Old Town",
                 postcode: "N1 1AA")
        end

        it "updates the site attributes" do
          expect { subject.save! }
            .to change(site, :location_name).from("Old Name").to("Test School")
            .and change(site, :address1).from("Old Street").to("123 Main Street")
            .and change(site, :town).from("Old Town").to("London")
            .and change(site, :postcode).from("N1 1AA").to("SW1A 1AA")
        end
      end

      context "when site has validation errors" do
        before do
          allow(site).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(site))
        end

        it "raises the validation error" do
          expect { subject.save! }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    describe "delegations" do
      let(:site) { create(:site, provider:) }

      it "delegates provider to site" do
        expect(subject.provider).to eq(provider)
      end

      it "delegates provider_code to provider" do
        expect(subject.provider_code).to eq(provider.provider_code)
      end

      it "delegates recruitment_cycle_year to provider" do
        expect(subject.recruitment_cycle_year).to eq(provider.recruitment_cycle_year)
      end
    end

    describe "#site" do
      it "returns the model" do
        expect(subject.site).to eq(site)
      end
    end

    describe "initialization" do
      it "assigns all fields from params" do
        expect(subject.location_name).to eq("Test School")
        expect(subject.address1).to eq("123 Main Street")
        expect(subject.address2).to eq("Building A")
        expect(subject.town).to eq("London")
        expect(subject.postcode).to eq("SW1A 1AA")
        expect(subject.urn).to eq("123456")
      end

      context "when site has existing attributes" do
        let(:site) do
          provider.sites.build(
            location_name: "Existing School",
            address1: "Existing Street",
            town: "Existing Town",
            postcode: "E1 1AA",
          )
        end

        context "with empty params" do
          let(:params) { {} }

          it "initializes with existing site attributes" do
            expect(subject.location_name).to eq("Existing School")
            expect(subject.address1).to eq("Existing Street")
            expect(subject.town).to eq("Existing Town")
            expect(subject.postcode).to eq("E1 1AA")
          end
        end

        context "with partial params" do
          let(:params) { { location_name: "Updated School" } }

          it "merges params with existing attributes" do
            expect(subject.location_name).to eq("Updated School")
            expect(subject.address1).to eq("Existing Street")
            expect(subject.town).to eq("Existing Town")
          end
        end
      end
    end
  end
end
