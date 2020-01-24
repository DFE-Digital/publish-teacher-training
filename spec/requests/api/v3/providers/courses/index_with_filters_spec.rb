require "rails_helper"

describe "GET v3/recruitment_cycle/:recruitment_cycle_year/courses" do
  let(:current_cycle) { create(:recruitment_cycle) }

  describe "funding filter" do
    context "filter[funding]=salary" do
      let(:request_path) { "/api/v3/recruitment_cycles/#{current_cycle.year}/courses?filter[funding]=salary" }

      context "salary course" do
        let(:expected_course) { create(:course, :with_salary) }

        before do
          expected_course
        end

        it "returns salary courses" do
          get request_path
          json_response = JSON.parse(response.body)
          course_hashes = json_response["data"]
          expect(course_hashes.count).to eq(1)
        end
      end

      context "non salaried course" do
        let(:non_salary_course) { create(:course, :with_salary) }

        before do
          non_salary_course
        end

        it "returns salary courses" do
          get request_path
          json_response = JSON.parse(response.body)
          course_hashes = json_response["data"]
          expect(course_hashes).to be_empty
        end
      end
    end
  end
end
