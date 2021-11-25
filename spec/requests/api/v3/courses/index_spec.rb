require "rails_helper"

describe "GET v3/recruitment_cycles/:year/courses" do
  let(:request_path) { "/api/v3/recruitment_cycles/#{RecruitmentCycle.current.year}/courses" }
  let(:current_course) do
    create(:course, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
  end

  let(:next_provider) { create(:provider, :next_recruitment_cycle) }
  let(:next_course) do
    create(:course, provider: next_provider, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
  end

  before do
    current_course
    next_course
  end

  describe "request_id" do
    it "stores request_id from header" do
      headers = { "X-Request-Id" => "hello" }
      hash = double
      expect(RequestStore).to receive(:store).and_return(hash)
      expect(hash).to receive(:[]=).with(:request_id, "hello")
      get request_path, headers: headers
    end
  end

  describe "pagination" do
    it "returns a paginated list of courses in the recruitment cycle" do
      get request_path

      json_response = JSON.parse(response.body)
      course_hashes = json_response["data"]

      expect(course_hashes.count).to eq(1)
      expect(course_hashes.first["id"]).to eq(current_course.id.to_s)
    end
  end

  describe "course count" do
    it "returns the course count in a meta object" do
      get request_path

      json_response = JSON.parse(response.body)
      meta = json_response["meta"]

      expect(meta["count"]).to be(1)
    end
  end

  describe "caching" do
    let!(:additional_course) do
      create(
        :course, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)]
      )
    end

    it "caches course hashes" do
      get request_path

      course_hashes = JSON.parse(response.body)["data"]
      expect(course_hashes.count).to eq(2)
      expect(course_hashes.map { |h| h["id"].to_i }).to match_array [current_course.id, additional_course.id]

      cached_data = Rails.cache.instance_variable_get(:@data)
      expect(
        cached_data.each_value.map do |cache_entry|
          JSON.parse(cache_entry.value)["id"].to_i
        end,
      ).to match_array [current_course.id, additional_course.id]
    end

    it "busts cache entries" do
      get request_path
      course_hashes = JSON.parse(response.body)["data"]
      expect(course_hashes.map { |h| h.dig("attributes", "name") }).to match_array [current_course.name, additional_course.name]

      current_course.update!(name: "Astronomy")
      get request_path
      course_hashes = JSON.parse(response.body)["data"]
      expect(course_hashes.map { |h| h.dig("attributes", "name") }).to match_array ["Astronomy", additional_course.name]
    end

    it "busts cache entries when included providers are updated" do
      request_path = "/api/v3/recruitment_cycles/#{RecruitmentCycle.current.year}/courses?include=provider"
      get request_path
      included_hashes = JSON.parse(response.body)["included"]

      expect(
        included_hashes.map { |h| h.dig("attributes", "provider_name") },
      ).to match_array [current_course.provider.provider_name, additional_course.provider.provider_name]

      additional_course.provider.update!(provider_name: "Fubar Ltd.")
      get request_path
      included_hashes = JSON.parse(response.body)["included"]

      expect(
        included_hashes.map { |h| h.dig("attributes", "provider_name") },
      ).to match_array [current_course.provider.provider_name, "Fubar Ltd."]
    end

    it "busts cache entries when sites are added to a course" do
      request_path = "/api/v3/recruitment_cycles/#{RecruitmentCycle.current.year}/courses?include=site_statuses.site,provider"
      get request_path

      included_hashes = JSON.parse(response.body)["included"]

      expect(
        included_hashes.map { |h| h.dig("attributes", "location_name") }.compact,
      ).to match_array [current_course.sites.first.location_name, additional_course.sites.first.location_name]

      additional_site = create(:site, location_name: "An additional site")

      create(:site_status, site: additional_site, course_id: additional_course.id)

      get request_path

      included_hashes = JSON.parse(response.body)["included"]

      expect(
        included_hashes.map { |h| h.dig("attributes", "location_name") }.compact,
      ).to match_array [current_course.sites.first.location_name, additional_course.sites.first.location_name, additional_site.location_name]
    end
  end
end

describe "GET v3/courses" do
  let(:findable_status) { build(:site_status, :findable) }
  let(:published_enrichment) { build(:course_enrichment, :published) }

  describe "location filter" do
    context "filters out courses with sites that are too far" do
      let(:provider_a) { create(:provider, provider_name: "Provider A") }
      let(:course_a) do
        create(:course,
               name: "Course A",
               provider: provider_a,
               site_statuses: [build(:site_status, :findable, site: build(:site, latitude: 0, longitude: 0))],
               enrichments: [build(:course_enrichment, :published)])
      end

      let(:provider_b) { create(:provider, provider_name: "Provider B") }
      let(:course_b) do
        create(
          :course,
          name: "Course B",
          provider: provider_b,
          site_statuses: [build(:site_status, :findable, site: build(:site, latitude: 16, longitude: 32))],
          enrichments: [build(:course_enrichment, :published)],
        )
      end

      before do
        course_a
        course_b
      end

      context "with a radius of 5" do
        let(:request_path) { "/api/v3/courses?include=provider&sort=name,provider.provider_name&filter[latitude]=0&filter[longitude]=0&filter[radius]=5" }

        it "returns only courses in range" do
          get request_path

          json_response = JSON.parse(response.body)
          course_hashes = json_response["data"]
          expect(course_hashes.count).to eq(1)
          expect(course_hashes.first["id"]).to eq(course_a.id.to_s)
        end
      end
    end
  end

  describe "ordering" do
    let(:provider_a) { create(:provider, provider_name: "Provider A") }
    let(:course_a) do
      create(:course,
             name: "Course A",
             provider: provider_a,
             site_statuses: [build(:site_status, :findable, site: far_site)],
             enrichments: [build(:course_enrichment, :published)])
    end

    let(:provider_b) { create(:provider, provider_name: "Provider B") }
    let(:course_b) do
      create(
        :course,
        name: "Course B",
        provider: provider_b,
        site_statuses: [build(:site_status, :findable, site: near_site)],
        enrichments: [build(:course_enrichment, :published)],
      )
    end
    let(:near_site) { build(:site, latitude: 1, longitude: 1) }
    let(:far_site) { build(:site, latitude: 2, longitude: 2) }

    before do
      course_a
      course_b
    end

    context "in ascending order" do
      let(:request_path) { "/api/v3/courses?include=provider&sort=name,provider.provider_name" }

      it "returns an ordered list" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.first["id"]).to eq(course_a.id.to_s)
        expect(course_hashes.second["id"]).to eq(course_b.id.to_s)
      end
    end

    context "in descending order" do
      let(:request_path) { "/api/v3/courses?include=provider&sort=-name,-provider.provider_name" }

      it "returns an ordered list" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.first["id"]).to eq(course_b.id.to_s)
        expect(course_hashes.second["id"]).to eq(course_a.id.to_s)
      end
    end

    context "by distance" do
      let(:request_path) { "/api/v3/courses?include=provider&sort=distance&latitude=0&longitude=0" }

      it "returns course with closest site first" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.first["id"]).to eq(course_b.id.to_s)
        expect(course_hashes.second["id"]).to eq(course_a.id.to_s)
      end

      context "when a course has 2 available sites" do
        let(:another_site) { build(:site, latitude: 0.5, longitude: 0.5) }

        before do
          course_b.site_statuses << create(:site_status, :findable, site: another_site)
        end

        let(:page_1) { "/api/v3/courses?sort=distance&latitude=0&longitude=0&page[page]=1" }
        let(:page_2) { "/api/v3/courses?sort=distance&latitude=0&longitude=0&page[page]=2" }
        let(:page_3) { "/api/v3/courses?sort=distance&latitude=0&longitude=0&page[page]=3" }

        # jsonapi removes duplicates on the same page
        # therefore this test needs to span multiple pages
        # in order for the test to be valid

        it "does not return duplicates" do
          course_ids = []

          allow_any_instance_of(API::V3::CoursesController).to receive(:max_per_page).and_return(1)

          get page_1

          json_response = JSON.parse(response.body)
          course_ids << json_response.dig("data", 0, "id")

          get page_2

          json_response = JSON.parse(response.body)
          course_ids << json_response.dig("data", 0, "id")

          get page_3

          json_response = JSON.parse(response.body)
          course_ids << json_response.dig("data", 0, "id")

          expect(course_ids.compact).to eql([course_b.id.to_s, course_a.id.to_s])
        end
      end

      context "when a course has a site with no address" do
        let(:nearest_site_with_no_address) do
          build(:site, address1: "", postcode: "", latitude: 0.5, longitude: 0.5).tap do |site|
            site.save(validate: false)
          end
        end

        before do
          course_a.site_statuses << build(:site_status, :findable, site: nearest_site_with_no_address)
        end

        it "ignores the invalid site in the distance ordering" do
          get request_path

          json_response = JSON.parse(response.body)
          course_hashes = json_response["data"]
          expect(course_hashes.first["id"]).to eq(course_b.id.to_s)
          expect(course_hashes.second["id"]).to eq(course_a.id.to_s)
        end
      end

      context "when a course has a site that has not been geocoded" do
        let(:ungeocoded_site) do
          build(:site, latitude: nil, longitude: nil)
        end

        before do
          course_a.site_statuses << build(:site_status, :findable, site: ungeocoded_site)
        end

        it "ignores the ungeocoded site in the distance ordering" do
          get request_path

          json_response = JSON.parse(response.body)
          course_hashes = json_response["data"]
          expect(course_hashes.first["id"]).to eq(course_b.id.to_s)
          expect(course_hashes.second["id"]).to eq(course_a.id.to_s)
        end
      end
    end
  end

  describe "without filter params" do
    let(:request_path) { "/api/v3/courses" }
    let(:current_course) do
      create(:course, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
    end

    let(:next_provider) { create(:provider, :next_recruitment_cycle) }
    let(:next_course) do
      create(:course, provider: next_provider, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
    end

    before do
      current_course
      next_course
    end

    it "returns a paginated list of current cycle courses" do
      get request_path

      json_response = JSON.parse(response.body)
      course_hashes = json_response["data"]
      expect(course_hashes.count).to eq(1)
      expect(course_hashes.first["id"]).to eq(current_course.id.to_s)
    end
  end

  describe "funding filter" do
    let(:request_path) { "/api/v3/courses?filter[funding]=salary" }

    context "with a salaried course" do
      let(:course_with_salary) { create(:course, :salary_type_based, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        course_with_salary
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with a non-salaried course" do
      let(:non_salary_course) { create(:course, :non_salary_type_based, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        non_salary_course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes).to be_empty
      end
    end
  end

  describe "degree grade filter" do
    let(:request_path) { "/api/v3/courses?filter[degree_grade]=two_two,third_class" }

    context "with one course that has a 2:2 degree grade and another that has a third class degree grade" do
      let(:course_with_two_two_degree) { create(:course, degree_grade: :two_two, site_statuses: [findable_status]) }
      let(:course_with_third_class_degree) { create(:course, degree_grade: :third_class, site_statuses: [build(:site_status, :findable)]) }

      before do
        course_with_two_two_degree
        course_with_third_class_degree
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]

        expect(course_hashes.count).to eq(2)
      end
    end

    context "with a course that has a 'not_required' degree grade" do
      let(:minimum_degree_not_required_course) { create(:course, degree_grade: :not_required, site_statuses: [findable_status]) }

      before { minimum_degree_not_required_course }

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]

        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "qualifications filter" do
    let(:request_path) { "/api/v3/courses?filter[qualification]=pgce" }

    context "with a pgce qualification" do
      let(:course_with_pgce) { create(:course, :resulting_in_pgce, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        course_with_pgce
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "without a pgce qualification" do
      let(:course_without_pgce) { create(:course, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        course_without_pgce
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "vacancies filter" do
    let(:request_path) { "/api/v3/courses?filter[has_vacancies]=true" }

    context "with a course with vacancies" do
      let(:findable_status_with_vacancies) { build(:site_status, :findable, :with_any_vacancy) }
      let(:course_with_vacancies) { create(:course, site_statuses: [findable_status_with_vacancies], enrichments: [published_enrichment]) }

      before do
        course_with_vacancies
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with a course with no vacancies" do
      let(:findable_status_with_no_vacancies) { build(:site_status, :findable, :with_no_vacancies) }
      let(:course_without_vacancies) { create(:course, site_statuses: [findable_status_with_no_vacancies], enrichments: [published_enrichment]) }

      before do
        course_without_vacancies
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "requesting courses ordered by distance with vacancy filter" do
    let(:findable_status_with_no_vacancies) { build(:site_status, :findable, :with_no_vacancies, site: build(:site, latitude: 0, longitude: 0)) }
    let(:findable_status_with_vacancies) { build(:site_status, :findable, :with_any_vacancy,  site: build(:site, latitude: 5, longitude: 5)) }
    let(:another_findable_status_with_vacancies) { build(:site_status, :findable, :with_any_vacancy, site: build(:site, latitude: 3, longitude: 3)) }
    let(:course_with_multiple_sites) { create(:course, provider: create(:provider), site_statuses: [findable_status_with_no_vacancies, findable_status_with_vacancies], enrichments: [published_enrichment]) }
    let(:course_with_single_site) { create(:course, provider: create(:provider), site_statuses: [another_findable_status_with_vacancies], enrichments: [published_enrichment]) }
    let(:request_path) { "/api/v3/courses?include=site_statuses.site&sort=distance&latitude=0&longitude=0&filter[has_vacancies]=#{has_vacancies?}" }

    context "has_vacancies filter is true " do
      let(:has_vacancies?) { true }

      before do
        course_with_single_site
        course_with_multiple_sites
      end

      it "the first course returned has the closest site with vacancies" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]

        expect(course_hashes.count).to eq(2)
        expect(course_hashes.first["id"]).to eq(course_with_single_site.id.to_s)
      end
    end

    context "has_vacancies filter is false" do
      let(:has_vacancies?) { false }

      before do
        course_with_single_site
        course_with_multiple_sites
      end

      it "the first course returned has the closest site, regardless of vacancy status" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]

        expect(course_hashes.count).to eq(2)

        expect(course_hashes.first["id"]).to eq(course_with_multiple_sites.id.to_s)
      end
    end
  end

  describe "study type filter" do
    let(:request_path) { "/api/v3/courses?filter[study_type]=full_time" }

    context "with a full time course" do
      let(:full_time_course) { create(:course, study_mode: :full_time, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        full_time_course
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with a part time course" do
      let(:part_time_course) { create(:course, study_mode: :part_time, enrichments: [published_enrichment]) }

      before do
        part_time_course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "subjects filter" do
    let(:course_with_A1_subject) do
      create(:course,
             enrichments: [published_enrichment],
             site_statuses: [findable_status],
             subjects: [create(:primary_subject, subject_code: "A1")])
    end

    context "with courses that match a single subject" do
      let(:request_path) { "/api/v3/courses?filter[subjects]=A1" }

      before do
        course_with_A1_subject
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with courses that match multiple subjects" do
      let(:request_path) { "/api/v3/courses?filter[subjects]=A1,B1" }
      let(:course_with_B1_subject) do
        create(:course,
               enrichments: [published_enrichment],
               site_statuses: [build(:site_status, :findable)],
               subjects: [create(:primary_subject, subject_code: "B1")])
      end

      before do
        course_with_A1_subject
        course_with_B1_subject
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(2)
      end
    end

    context "with courses that match no subjects" do
      let(:request_path) { "/api/v3/courses?filter[subjects]=C1" }

      before do
        course_with_A1_subject
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "provider filter" do
    context "with a provider specified" do
      let(:request_path) { "/api/v3/courses?filter[provider.provider_name]=#{filtered_provider_course.provider.provider_name}" }
      let(:provider_filtered_by) { create(:provider) }
      let(:filtered_provider_course) { create(:course, provider: provider_filtered_by, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        provider_filtered_by
        filtered_provider_course
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with a different provider specified" do
      let(:request_path) { "/api/v3/courses?filter[provider.provider_name]=a+different+provider" }
      let(:provider_excluded) { create(:provider) }
      let(:excluded_provider_course) { create(:course, provider: provider_excluded, site_statuses: [build(:site_status, :findable)], enrichments: [published_enrichment]) }

      before do
        provider_excluded
        excluded_provider_course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end

    context "with an accredited body which delivers its own courses" do
      let(:request_path) { "/api/v3/courses?filter[provider.provider_name]=#{provider_filtered_by.provider_name}" }
      let(:provider_filtered_by) { create(:provider, :accredited_body, provider_name: "The University of Warwick") }
      let(:another_training_provider) { create(:provider, provider_name: "Anglia College") }
      let(:site2) { build(:site) }
      let(:site1) { build(:site) }
      let(:filtered_provider_course) {
        create(:course,
               name: "Course A",
               provider: provider_filtered_by,
               accrediting_provider: provider_filtered_by,
               site_statuses: [create(:site_status, :findable, site: site1)],
               enrichments: [published_enrichment])
      }
      let(:another_provider_course) {
        create(:course,
               name: "Course B",
               provider: another_training_provider,
               accrediting_provider: provider_filtered_by,
               site_statuses: [create(:site_status, :findable, site: site2)],
               enrichments: [published_enrichment])
      }

      before do
        provider_filtered_by
        filtered_provider_course
        another_training_provider
        another_provider_course
      end

      it "its courses are returned first" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]

        expect(course_hashes.first.dig("attributes").dig("name")).to eq(filtered_provider_course.name)
        expect(course_hashes.second.dig("attributes").dig("name")).to eq(another_provider_course.name)
      end
    end
  end

  describe "SEND courses filter" do
    let(:request_path) { "/api/v3/courses?filter[send_courses]=true" }

    context "with a SEND course" do
      let(:send_course) { create(:course, is_send: true, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        send_course
      end

      it "is returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(1)
      end
    end

    context "with a course without SEND specialism" do
      let(:course) { create(:course, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "recruitment_cycle scoping" do
    context "course not in the provided recruitment cycle" do
      let(:provider) { create(:provider, :next_recruitment_cycle) }
      let(:request_path) { "/api/v3/courses" }

      let(:course_in_next_cycle) { create(:course, provider: provider, site_statuses: [findable_status], enrichments: [published_enrichment]) }

      before do
        course_in_next_cycle
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "findable scoping" do
    context "course is not findable" do
      let(:request_path) { "/api/v3/courses" }
      let(:not_findable_course) { create(:course) }

      before do
        not_findable_course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "published scoping" do
    context "course is not currently published" do
      let(:request_path) { "/api/v3/courses" }
      let(:not_published_course) { create(:course, enrichments: [build(:course_enrichment, :withdrawn)]) }

      before do
        not_published_course
      end

      it "is not returned" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(0)
      end
    end
  end

  describe "visa scoping" do
    context "with providers that can and cannot provide visas" do
      let(:request_path) { "/api/v3/courses?filter[can_sponsor_visa]=true" }
      let(:provider_that_can_sponsor_student_visa) { build(:provider, can_sponsor_student_visa: true, can_sponsor_skilled_worker_visa: false) }
      let(:provider_that_can_sponsor_skilled_worker_visa) { build(:provider, can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: true) }
      let(:provider_that_cant_sponsor_visas) { build(:provider, can_sponsor_student_visa: false, can_sponsor_skilled_worker_visa: false) }
      let(:course1) { create(:course, :fee_type_based, provider: provider_that_can_sponsor_student_visa, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)]) }
      let(:course2) { create(:course, :salary_type_based, provider: provider_that_can_sponsor_skilled_worker_visa, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)]) }
      let(:course3) { create(:course, provider: provider_that_cant_sponsor_visas, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)]) }

      before do
        course1
        course2
        course3
      end

      it "returns courses where the provider can offer visas" do
        get request_path
        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(2)
      end
    end
  end

  describe "pagination" do
    let(:request_path) { "/api/v3/courses" }

    context "can be disabled for sitemap" do
      before do
        create(:course, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
        create(:course, site_statuses: [build(:site_status, :findable)], enrichments: [build(:course_enrichment, :published)])
      end

      let(:request_path) { "/api/v3/courses?page[per_page]=1000&fields[courses]=course_code,provider_code,changed_at" }

      it "returns all results" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.count).to eq(2)
      end

      it "returns only specified fields" do
        get request_path

        keys = JSON.parse(response.body)["data"][0]["attributes"].keys
        expect(keys).to eql(%w{course_code changed_at provider_code})
      end
    end
  end
end
