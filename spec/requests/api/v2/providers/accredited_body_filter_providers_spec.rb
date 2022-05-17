require "rails_helper"

describe "AccreditedBody API v2", type: :request do
  describe "GET /providers" do
    let(:user) { create(:user) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:credentials) { encode_to_credentials(payload) }

    let(:physical_education) { find_or_create(:secondary_subject, :physical_education) }
    let(:biology) { find_or_create(:secondary_subject, :biology) }

    let(:unfunded_pe_course) do
      create(:course,
             level: :secondary,
             provider: training_provider_1,
             subjects: [physical_education],
             site_statuses: [build(:site_status, :findable, site: build(:site))],
             accrediting_provider: accredited_provider)
    end

    let(:accredited_provider_course) do
      create(:course,
             level: :secondary,
             provider: accredited_provider,
             subjects: [physical_education],
             site_statuses: [build(:site_status, :findable, site: build(:site))],
             accrediting_provider: nil) # important the course is not accredited
    end

    let(:training_provider_1) { create(:provider, provider_name: "ABC Provider") }

    let(:accredited_provider) {
      create(:provider,
             users: [user],
             recruitment_cycle: recruitment_cycle)
    }

    let(:json_response) { JSON.parse(response.body) }

    let(:request_path) {
      "/api/v2/recruitment_cycles/#{recruitment_cycle.year}/providers/#{accredited_provider.provider_code}/training_providers#{filters}"
    }

    def provider_names_in_response(provider_hashes)
      provider_hashes.map { |provider|
        provider["attributes"]["provider_name"]
      }
    end

    def perform_request
      get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    context "when accredited_provider has a self-accredited course" do
      before do
        accredited_provider_course
      end

      let(:filters) { "" }

      it "returns the accredited provider in the results" do
        get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
        json_response = JSON.parse(response.body)
        provider_hashes = json_response["data"]
        expect(provider_hashes.map { |h| h["id"].to_i }).to include(accredited_provider.id)
      end
    end

    describe "funding type filter" do
      let(:fee_funded_course) do
        create(:course,
               level: :secondary,
               program_type: :school_direct_training_programme,
               provider: training_provider_1,
               site_statuses: [build(:site_status, :findable, site: build(:site))],
               accrediting_provider: accredited_provider)
      end

      context "with training providers offering courses that match a single funding type" do
        let(:filters) { "?filter[funding_type]=fee" }

        before do
          fee_funded_course
        end

        it "is returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(1)
        end
      end

      context "with training providers offering courses that match multiple funding types" do
        let(:training_provider_2) { create(:provider, provider_name: "BCD Provider") }

        let(:salary_funded_course) do
          create(:course,
                 level: :secondary,
                 program_type: :school_direct_salaried_training_programme,
                 provider: training_provider_2,
                 site_statuses: [build(:site_status, :findable, site: build(:site))],
                 accrediting_provider: accredited_provider)
        end

        let(:filters) { "?filter[funding_type]=fee,salary" }

        before do
          fee_funded_course
          salary_funded_course
        end

        it "is returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(2)
          expect(provider_names_in_response(provider_hashes)).to eq(["ABC Provider", "BCD Provider"])
        end
      end

      context "with training providers offering courses that match no funding type" do
        let(:filters) { "?filter[funding_type]=salary" }

        before do
          fee_funded_course
        end

        it "is not returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(0)
        end
      end
    end

    describe "subject type filter" do
      let(:physical_education) { find_or_create(:secondary_subject, :physical_education) }
      let(:biology) { find_or_create(:secondary_subject, :biology) }

      let(:pe_course) do
        create(:course,
               level: :secondary,
               provider: training_provider_1,
               subjects: [physical_education],
               site_statuses: [build(:site_status, :findable, site: build(:site))],
               accrediting_provider: accredited_provider)
      end

      context "with training providers offering courses that match a single subject type" do
        let(:filters) { "?filter[subjects]=#{physical_education.subject_code}" }

        before do
          pe_course
        end

        it "is returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(1)
        end
      end

      context "with training providers offering courses that match multiple subject" do
        let(:training_provider_2) { create(:provider, provider_name: "BCD Provider") }

        let(:biology_course) do
          create(:course,
                 level: :secondary,
                 provider: training_provider_2,
                 subjects: [biology],
                 site_statuses: [build(:site_status, :findable, site: build(:site))],
                 accrediting_provider: accredited_provider)
        end

        let(:filters) { "?filter[subjects]=#{physical_education.subject_code},#{biology.subject_code}" }

        before do
          pe_course
          biology_course
        end

        it "is returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(2)
          expect(provider_names_in_response(provider_hashes)).to eq(["ABC Provider", "BCD Provider"])
        end
      end

      context "with training providers offering courses that match no subjects" do
        let(:filters) { "?filter[subjects]=#{biology.subject_code}" }

        before do
          pe_course
        end

        it "is not returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(0)
        end
      end
    end

    describe "combined fee and subject filter" do
      context "with training providers offering courses that match a subject and funding type but are accredited by different provider" do
        let(:filters) { "?filter[subject]=#{physical_education.subject_code}&filter[funding_type]=fee" }
        let(:training_provider_2) { create(:provider) }

        let(:accredited_provider_2) {
          create(:provider,
                 users: [create(:user)],
                 recruitment_cycle: recruitment_cycle)
        }

        let(:fee_paying_pe_course_1) do
          create(:course,
                 level: :secondary,
                 provider: training_provider_1,
                 program_type: :school_direct_training_programme,
                 subjects: [physical_education],
                 site_statuses: [build(:site_status, :findable, site: build(:site))],
                 accrediting_provider: accredited_provider)
        end

        let(:fee_paying_pe_course_2) do
          create(:course,
                 level: :secondary,
                 provider: training_provider_2,
                 subjects: [physical_education],
                 program_type: :school_direct_training_programme,
                 site_statuses: [build(:site_status, :findable, site: build(:site))],
                 accrediting_provider: accredited_provider_2)
        end

        let(:non_fee_pe_course) do
          create(:course,
                 level: :secondary,
                 provider: training_provider_2,
                 subjects: [physical_education],
                 site_statuses: [build(:site_status, :findable, site: build(:site))],
                 accrediting_provider: accredited_provider)
        end

        before do
          fee_paying_pe_course_1
          fee_paying_pe_course_2
          non_fee_pe_course
        end

        it "is not returned" do
          get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
          json_response = JSON.parse(response.body)
          provider_hashes = json_response["data"]
          expect(provider_hashes.count).to eq(1)
        end
      end
    end
  end
end
