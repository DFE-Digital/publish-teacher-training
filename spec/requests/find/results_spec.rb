# frozen_string_literal: true

require "rails_helper"

describe "/results" do
  context "when page parameter is invalid" do
    before do
      get "/results", params: { page: "some-site-.co.uk" }
    end

    it "responds successfully" do
      expect(response).to have_http_status(:ok)
    end
  end

  describe "grouping courses into cards" do
    let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }
    let(:event) { instance_double(Find::Analytics::SearchResultsEvent, send_event: nil) }
    let(:page) { Nokogiri::HTML(response.body) }

    # 6 providers with 2 Maths courses each: 12 courses on 6 cards.
    let!(:courses) do
      create_list(:provider, 6).flat_map do |provider|
        create_list(:course, 2, :secondary, :with_full_time_sites, :published, provider:, name: "Mathematics", subjects: [mathematics], master_subject_id: mathematics.id)
      end
    end

    before do
      allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
      allow(Find::Analytics::SearchResultsEvent).to receive(:new).and_return(event)
    end

    context "when the group_search_results flag is on" do
      before do
        FeatureFlag.activate(:group_search_results)
        get "/results"
      end

      it "shows one card per provider, with each course listed on it" do
        expect(page.css(".app-search-results__item").size).to eq(6)
        expect(page.css(".app-search-results__item h2.govuk-summary-card__title").size).to eq(6)
        expect(page.css(".app-search-results__item h3 a.app-search-result__course-name").size).to eq(12)
        expect(page.css(".govuk-pagination__next")).to be_empty
      end

      it "lists each provider's own courses on its card" do
        page.css(".app-search-results__item").each do |card|
          provider = Provider.find_by!(provider_name: card.at_css("h2").text.strip)
          course_names = card.css("h3 a").map { |link| link.text.squish }

          expect(course_names).to match_array(provider.courses.map { |course| "#{course.name_and_code} at #{provider.provider_name}" })
        end
      end

      it "shows a provider with one course as today's card" do
        provider = create(:provider, provider_name: "Solo SCITT")
        create(:course, :secondary, :with_full_time_sites, :published, provider:, name: "Mathematics", subjects: [mathematics], master_subject_id: mathematics.id)

        get "/results"
        card = page.css("li.app-search-results__item").find { |item| item.at_css("h2")&.text&.include?("Solo SCITT") }

        expect(card.css("> .govuk-summary-card h2.govuk-summary-card__title").text).to include("Solo SCITT")
        expect(card.css(".govuk-summary-card__content > h3 > a.app-search-result__course-name").size).to eq(1)
        expect(card.css(".app-search-result__course")).to be_empty
      end

      it "handles a search with a question mark" do
        get "/results", params: { provider_name: "Who?" }

        expect(response).to have_http_status(:ok)
      end

      it "still counts courses" do
        expect(page.text).to include("12 results")
      end

      context "when candidates can save courses" do
        before do
          FeatureFlag.activate(:candidate_accounts)
          get "/results"
        end

        it "gives each course on a card its own Save" do
          course_ids = page.css("a[href*='saved-courses/sign_in']").map { |link| Rack::Utils.parse_query(URI(link["href"]).query)["course_id"].to_i }

          expect(course_ids.uniq).to match_array(courses.map(&:id))
        end
      end

      it "sends the courses on the page to analytics" do
        expect(Find::Analytics::SearchResultsEvent).to have_received(:new) do |args|
          expect(args.slice(:total, :page)).to eq(total: 12, page: 1)
          expect(args[:results].map(&:id)).to match_array(courses.map(&:id))
        end
      end
    end

    context "when the group_search_results flag is off" do
      before { get "/results" }

      it "shows 10 courses a page" do
        expect(page.css(".app-search-results__item").size).to eq(10)
        expect(page.css(".govuk-pagination__next")).to be_present
      end

      it "counts courses" do
        expect(page.text).to include("12 results")
      end
    end
  end

  describe "salaried courses under the fee sorts" do
    let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }
    let(:page) { Nokogiri::HTML(response.body) }

    let(:ashford) { create(:provider, provider_name: "Ashford Teacher Training") }
    let(:bexley) { create(:provider, provider_name: "Bexley SCITT") }

    def create_course(provider:, course_code:, funding: "fee", fee: nil)
      create(:course, :secondary, :with_full_time_sites, :published, provider:, course_code:, funding:, name: "Mathematics", subjects: [mathematics], master_subject_id: mathematics.id, enrichments: [build(:course_enrichment, :published, fee_uk_eu: fee)])
    end

    def cards
      page.css(".app-search-results__item").map { |card| card.css("h3 a").map { |link| link.text[/\((\w+)\)/, 1] } }
    end

    before do
      create_course(provider: ashford, course_code: "A001", fee: 9_000)
      create_course(provider: bexley, course_code: "B001", fee: 10_000)
      create_course(provider: ashford, course_code: "A002", funding: "salary")
    end

    context "when the group_search_results flag is on" do
      before { FeatureFlag.activate(:group_search_results) }

      it "puts a provider's salaried course on its fee card" do
        get "/results", params: { order: "fee_uk_ascending" }

        expect(cards).to eq([%w[A001 A002], %w[B001]])
      end
    end

    context "when the group_search_results flag is off" do
      it "puts salaried courses last, as today" do
        get "/results", params: { order: "fee_uk_ascending" }

        expect(cards).to eq([%w[A001], %w[B001], %w[A002]])
      end
    end
  end

  describe "tracking the start date filter" do
    let(:event) { instance_double(Find::Analytics::SearchResultsEvent, send_event: nil) }

    before do
      allow(Settings.features).to receive(:send_request_data_to_bigquery).and_return(true)
      allow(Find::Analytics::SearchResultsEvent).to receive(:new).and_return(event)
    end

    it "sends the selected start date options" do
      get "/results", params: { start_date: %w[september next_jul] }

      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(search_params: hash_including(start_date: %w[september next_jul])),
      )
    end

    it "sends the options that replaced one the filter used to offer" do
      get "/results", params: { start_date: %w[jan_to_aug] }

      expect(Find::Analytics::SearchResultsEvent).to have_received(:new).with(
        hash_including(search_params: hash_including(start_date: %w[jan_to_mar apr_to_jun jul_to_aug])),
      )
    end
  end
end
