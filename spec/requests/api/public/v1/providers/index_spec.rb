require "rails_helper"

describe "GET public/v1/recruitment_cycle/:recruitment_cycle_year/providers" do
  let(:organisation) { create(:organisation) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }

  let!(:provider) do
    create(:provider,
           provider_code: "1AT",
           provider_name: "First",
           organisations: [organisation],
           contacts: [contact])
  end

  let(:contact) { build(:contact) }

  let(:json_response) { JSON.parse(subject.body) }
  let(:data) { json_response["data"] }

  def perform_request
    get request_path
  end

  subject do
    perform_request

    response
  end

  let(:request_path) do
    "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers"
  end

  describe "JSON generated for a providers" do
    it { should have_http_status(:success) }

    it "has a data section with the correct attributes" do
      expect(json_response).to eq(
        "data" => [{
          "id" => provider.id.to_s,
          "type" => "providers",
          "attributes" => {
            "code" => provider.provider_code,
            "name" => provider.provider_name,
            "recruitment_cycle_year" => provider.recruitment_cycle.year,
            "postcode" => provider.postcode,
            "provider_type" => provider.provider_type,
            "region_code" => provider.region_code,
            "train_with_disability" => provider.train_with_disability,
            "train_with_us" => provider.train_with_us,
            "website" => provider.website,
            "accredited_body" => provider.accredited_body?,
            "changed_at" => provider.changed_at.iso8601,
            "city" => provider.address3,
            "county" => provider.address4,
            "created_at" => provider.created_at.iso8601,
            "street_address_1" => provider.address1,
            "street_address_2" => provider.address2,
          },
        }],
        "jsonapi" => {
          "version" => "1.0",
        },
      )
    end
  end

  describe "sorting" do
    let!(:provider2) do
      create(:provider,
             provider_code: "0AT",
             provider_name: "Before",
             organisations: [organisation],
             contacts: [contact])
    end

    let!(:provider3) do
      create(:provider,
             provider_code: "2AT",
             provider_name: "Second",
             organisations: [organisation],
             contacts: [contact])
    end

    let(:provider_names_in_response) do
      data.map { |provider|
        provider["attributes"]["name"]
      }
    end

    context "default ordering" do
      it "returns them in a-z order" do
        expect(provider_names_in_response).to eq(%w(Before First Second))
      end

      describe "passing in sort param" do
        let(:request_path) do
          "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers?sort=#{sort_field}"
        end

        context "name" do
          let(:sort_field) { "name" }


          it "returns them in a-z order" do
            expect(provider_names_in_response).to eq(%w(Before First Second))
          end
        end

        context "-name" do
          let(:sort_field) { "-name" }

          it "returns them in z-a order" do
            expect(provider_names_in_response).to eq(%w(Second First Before))
          end
        end

        context "name,-name" do
          let(:sort_field) { "name,-name" }

          it "returns them in a-z order" do
            expect(provider_names_in_response).to eq(%w(Before First Second))
          end
        end

        context "-name,name" do
          let(:sort_field) { "-name,name" }

          it "returns them in a-z order" do
            expect(provider_names_in_response).to eq(%w(Before First Second))
          end
        end
      end
    end
  end

  context "with two recruitment cycles" do
    let(:next_recruitment_cycle) { create :recruitment_cycle, :next }
    let!(:next_provider) do
      create :provider,
             organisations: [organisation],
             provider_code: provider.provider_code,
             recruitment_cycle: next_recruitment_cycle
    end

    describe "making a request without specifying a recruitment cycle" do
      it "only returns data for the current recruitment cycle" do
        expect(data.count).to eq 1
        expect(data.first)
          .to have_attribute("recruitment_cycle_year")
                .with_value(recruitment_cycle.year)
      end
    end

    describe "making a request for the next recruitment cycle" do
      let(:request_path) do
        "/api/public/v1/recruitment_cycles/#{next_recruitment_cycle.year}/providers"
      end

      it "only returns data for the next recruitment cycle" do
        expect(data.count).to eq 1
        expect(data.first)
          .to have_attribute("recruitment_cycle_year")
                .with_value(next_recruitment_cycle.year)
      end
    end
  end

  context "Sparse fields" do
    context "Only returning specified fields" do
      let(:request_path) { "/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers?fields[providers]=name,recruitment_cycle_year" }

      it "Only returns the specified field" do
        expect(data.first["attributes"].keys.count).to eq(2)
        expect(data.first).to have_attribute("name")
        expect(data.first).to have_attribute("recruitment_cycle_year")
      end
    end

    context "Default fields" do
      fields = %w[ postcode
                   provider_type
                   region_code
                   train_with_disability
                   train_with_us
                   website
                   accredited_body
                   changed_at
                   city
                   code
                   county
                   created_at
                   name
                   recruitment_cycle_year
                   street_address_1
                   street_address_2]

      it "Returns the Default fields" do
        expect(data.first["attributes"].keys).to match_array(fields)
      end
    end
  end
end
