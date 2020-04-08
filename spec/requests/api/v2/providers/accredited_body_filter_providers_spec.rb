require "rails_helper"

describe "AccreditedBody API v2", type: :request do
  describe "GET /providers" do
    let(:user) { create(:user, organisations: [organisation]) }
    let(:organisation) { create(:organisation) }
    let(:recruitment_cycle) { find_or_create :recruitment_cycle }
    let(:payload) { { email: user.email } }
    let(:token) do
      JWT.encode payload,
                 Settings.authentication.secret,
                 Settings.authentication.algorithm
    end
    let(:credentials) do
      ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    let(:physical_education) { find_or_create(:secondary_subject, :physical_education) }
    let(:biology) { find_or_create(:secondary_subject, :biology) }

    let(:unfunded_pe_course) do
      create(:course,
             level: :secondary,
             provider: delivering_provider1,
             subjects: [physical_education],
             site_statuses: [build(:site_status, :findable, site: build(:site))],
             accrediting_provider: accredited_provider)
    end

    let(:fee_funded_pe_course) do
      create(:course,
             level: :secondary,
             program_type: :school_direct_training_programme,
             provider: delivering_provider1,
             subjects: [physical_education],
             site_statuses: [build(:site_status, :findable, site: build(:site))],
             accrediting_provider: accredited_provider)
    end

    let(:non_pe_course) do
      create(:course,
             level: :secondary,
             provider: delivering_provider2,
             subjects: [biology],
             site_statuses: [build(:site_status, :findable, site: build(:site))],
             accrediting_provider: accredited_provider)
    end

    let(:delivering_provider1) { create(:provider) }
    let(:delivering_provider2) { create(:provider) }
    let(:accredited_provider) {
      create(:provider,
             organisations: [organisation],
             recruitment_cycle: recruitment_cycle)
    }

    let(:json_response) { JSON.parse(response.body) }

    let(:request_path) {
      "/api/v2/recruitment_cycles/#{recruitment_cycle.year}/providers/#{accredited_provider.provider_code}/training_providers#{filters}"
    }

    def perform_request
      get request_path, headers: { "HTTP_AUTHORIZATION" => credentials }
    end

    describe "funding type filter" do
      let(:fee_funded_course) do
        create(:course,
               level: :secondary,
               program_type: :school_direct_training_programme,
               provider: delivering_provider1,
               site_statuses: [build(:site_status, :findable, site: build(:site))],
               accrediting_provider: accredited_provider)
      end

      context "with providers offering courses that match a single funding type" do
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

      context "with providers offering courses that match multiple funding types" do
        let(:salary_funded_course) do
          create(:course,
                 level: :secondary,
                 program_type: :school_direct_salaried_training_programme,
                 provider: delivering_provider2,
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
        end
      end

      context "with providers offering courses that match no funding type" do
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
               provider: delivering_provider1,
               subjects: [physical_education],
               site_statuses: [build(:site_status, :findable, site: build(:site))],
               accrediting_provider: accredited_provider)
      end

      context "with providers offering courses that match a single subject type" do
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

      context "with providers offering courses that match multiple subject" do
        let(:biology_course) do
          create(:course,
                 level: :secondary,
                 provider: delivering_provider2,
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
        end
      end

      context "with providers offering courses that match no subjects" do
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
  end
end
