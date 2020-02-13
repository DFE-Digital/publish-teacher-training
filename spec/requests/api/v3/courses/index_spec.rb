require "rails_helper"

describe "GET v3/recruitment_cycles/:year/courses" do
  let(:request_path) { "/api/v3/recruitment_cycles/2020/courses" }
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

  it "returns a paginated list of courses in the recruitment cycle" do
    get request_path

    json_response = JSON.parse(response.body)
    course_hashes = json_response["data"]
    expect(course_hashes.count).to eq(1)
    expect(course_hashes.first["id"]).to eq(current_course.id.to_s)

    headers = response.headers

    expect(headers["Per-Page"]).to be_present
    expect(headers["Total"]).to be_present
  end
end

describe "GET v3/courses" do
  let(:findable_status) { build(:site_status, :findable) }
  let(:published_enrichment) { build(:course_enrichment, :published) }

  context "ordering" do
    let(:provider_a) { create(:provider, provider_name: "Provider A") }
    let(:course_a) do
      create(:course,
             name: "Course A",
             provider: provider_a,
             site_statuses: [build(:site_status, :findable)],
             enrichments: [build(:course_enrichment, :published)])
    end

    let(:provider_b) { create(:provider, provider_name: "Provider B") }
    let(:course_b) do
      create(
        :course,
        name: "Course A",
        provider: provider_b,
        site_statuses: [build(:site_status, :findable)],
        enrichments: [build(:course_enrichment, :published)],
      )
    end

    before do
      course_a
      course_b
    end

    context "in ascending order" do
      let(:request_path) { "/api/v3/courses?include=provider&sort=provider.provider_name" }

      it "returns an ordered list" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.first["id"]).to eq(course_a.id.to_s)
        expect(course_hashes.second["id"]).to eq(course_b.id.to_s)
        #Course.includes(:provider).order("provider.provider_name")
      end
    end

    context "in descending order" do
      let(:request_path) { "/api/v3/courses?include=provider&sort=-provider.provider_name" }

      it "returns an ordered list" do
        get request_path

        json_response = JSON.parse(response.body)
        course_hashes = json_response["data"]
        expect(course_hashes.first["id"]).to eq(course_b.id.to_s)
        expect(course_hashes.second["id"]).to eq(course_a.id.to_s)
      end
    end
  end

  context "without filter params" do
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

      headers = response.headers

      expect(headers["Per-Page"]).to be_present
      expect(headers["Total"]).to be_present
    end
  end

  describe "funding filter" do
    let(:request_path) { "/api/v3/courses?filter[funding]=salary" }

    context "with a salaried course" do
      let(:course_with_salary) { create(:course, :with_salary, site_statuses: [findable_status], enrichments: [published_enrichment]) }

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
      let(:non_salary_course) { create(:course, site_statuses: [findable_status], enrichments: [published_enrichment]) }

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

  describe "pagination" do
    let(:request_path) { "/api/v3/courses" }

    it "paginates the results" do
      get request_path
      headers = response.headers

      expect(headers["Per-Page"]).to be_present
      expect(headers["Total"]).to be_present
    end
  end
end
