# frozen_string_literal: true

require "rails_helper"

RSpec.describe Courses::Query do # rubocop:disable RSpec/SpecFilePathFormat
  subject(:results) { described_class.call(params:) }

  let(:mathematics) { find_or_create(:secondary_subject, :mathematics) }
  let(:location) { { latitude: 52.4862, longitude: -1.8904, radius: 10 } }

  # Pages through the results the way Pagy does, with LIMIT and OFFSET.
  def ids_page_by_page(relation, count:, per_page: 5)
    (0...count).step(per_page).flat_map { |offset| relation.limit(per_page).offset(offset).map(&:id) }
  end

  describe "the final sort key" do
    %w[
      distance
      course_name_ascending
      provider_name_ascending
      newest_course
      start_date_ascending
      fee_uk_ascending
      fee_intl_ascending
    ].each do |order|
      context "when ordering by #{order}" do
        let(:params) { location.merge(order:) }

        it "breaks ties by course id" do
          expect(results.to_sql).to match(/ORDER BY .*"?course"?\."?id"? ASC\z/)
        end
      end
    end
  end

  context "when courses tie on every sort column across a page boundary" do
    let(:provider) { create(:provider, provider_name: "NITE") }
    let(:school) { create(:gias_school, latitude: 52.4862, longitude: -1.8904) }
    let(:params) { location.merge(subjects: [mathematics.subject_code], order: "distance") }

    let!(:tied_courses) do
      create_list(
        :course,
        12,
        :secondary,
        :published,
        provider:,
        subjects: [mathematics],
        master_subject_id: mathematics.id,
      ).each { |course| create(:course_school, course:, gias_school: school) }
    end

    it "shows each course exactly once, in course id order" do
      ids = ids_page_by_page(results, count: tied_courses.size)

      expect(ids).to eq(tied_courses.map(&:id).sort)
    end

    it "returns the same courses in the same order every time" do
      second_page = tied_courses.map(&:id).sort[5, 5]

      2.times do
        expect(described_class.call(params: params.dup).limit(5).offset(5).map(&:id)).to eq(second_page)
      end
    end
  end
end
