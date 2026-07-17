# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::NewCourseCopier do
  subject(:copy_schools) { described_class.new.call(course:, new_provider:, new_course:) }

  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school) }
  let!(:provider_school) { create(:provider_school, provider:, gias_school:, site_code: "B") }
  let!(:main_site) { create(:provider_school, :main_site, provider:, gias_school:) }
  let!(:course_school) do
    create(:course_school, course:, provider_school:, gias_school:, site_code: provider_school.site_code)
  end
  let!(:course_main_site) do
    create(:course_school, :main_site, course:, provider_school: main_site, gias_school:)
  end

  let(:new_provider) { create(:provider, recruitment_cycle: create(:recruitment_cycle, :next)) }
  let(:new_course) { create(:course, provider: new_provider, course_code: course.course_code) }
  let!(:new_provider_school) do
    create(:provider_school, provider: new_provider, gias_school:, site_code: provider_school.site_code)
  end
  let!(:new_main_site) { create(:provider_school, :main_site, provider: new_provider, gias_school:) }

  it "copies relationships to the copied course and matching copied provider schools" do
    copy_schools

    copied_relationships = new_course.schools.map do |school|
      [school.provider_school_id, school.gias_school_id, school.site_code]
    end

    expect(copied_relationships).to contain_exactly(
      [new_provider_school.id, course_school.gias_school_id, course_school.site_code],
      [new_main_site.id, course_main_site.gias_school_id, course_main_site.site_code],
    )
  end

  it "does not create legacy site statuses" do
    expect { copy_schools }.not_to change(new_course.site_statuses, :count)
  end
end
