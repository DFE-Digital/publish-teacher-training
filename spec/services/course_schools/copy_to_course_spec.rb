# frozen_string_literal: true

require "rails_helper"

RSpec.describe CourseSchools::CopyToCourse do
  subject(:copy_schools) { described_class.new.call(course:, new_provider:, new_course:) }

  # A provider school and the legacy site it was dual-written with, joined by
  # the uuid the two share.
  def link_school(provider, gias_school, site_code: "B")
    site = create(:site, provider:, urn: gias_school.urn, code: site_code)
    create(:provider_school, provider:, gias_school:, site_code:, uuid: site.uuid)
  end

  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:) }
  let(:gias_school) { create(:gias_school, :open) }
  let!(:provider_school) { link_school(provider, gias_school) }
  let!(:course_school) { create(:course_school, course:, provider_school:, gias_school:) }

  let(:new_provider) { create(:provider) }
  let(:new_course) { create(:course, provider: new_provider, course_code: course.course_code) }

  context "when the target provider already has the school" do
    # The target keeps its own site code for the same school.
    let!(:new_provider_school) { link_school(new_provider, gias_school, site_code: "K") }

    it "copies the course school onto the copied course" do
      copy_schools

      expect(new_course.schools.reload.map { |school| [school.provider_school_id, school.gias_school_id] })
        .to contain_exactly([new_provider_school.id, gias_school.id])
    end

    it "attaches the target provider's paired legacy site to the copied course" do
      copy_schools

      expect(new_course.site_statuses.reload.map(&:site))
        .to contain_exactly(new_provider.sites.find_by!(uuid: new_provider_school.uuid))
    end

    it "does not add any schools to the target provider" do
      expect { copy_schools }.to not_change(new_provider.schools, :count).and not_change(new_provider.sites, :count)
    end

    it "copies the school once when the source course reaches it through two of its own schools" do
      duplicate = create(:provider_school, provider:, gias_school:, site_code: "C")
      create(:course_school, course:, provider_school: duplicate, gias_school:)

      copy_schools

      expect(new_course.schools.reload.pluck(:provider_school_id)).to eq([new_provider_school.id])
    end
  end

  context "when the target provider does not have the school" do
    it "copies nothing" do
      copy_schools

      expect(new_course.schools.reload).to be_empty
      expect(new_course.site_statuses.reload).to be_empty
    end

    it "does not create the school for the target provider" do
      expect { copy_schools }.to not_change(new_provider.schools, :count).and not_change(new_provider.sites, :count)
    end

    it "still copies the schools the target provider does have" do
      other_gias_school = create(:gias_school, :open)
      other_provider_school = link_school(provider, other_gias_school, site_code: "C")
      create(:course_school, course:, provider_school: other_provider_school, gias_school: other_gias_school)
      new_provider_school = link_school(new_provider, other_gias_school, site_code: "D")

      copy_schools

      expect(new_course.schools.reload.pluck(:provider_school_id)).to eq([new_provider_school.id])
    end
  end

  context "when the source course school's GIAS record has closed" do
    let(:gias_school) { create(:gias_school, :closed) }
    let!(:new_provider_school) { link_school(new_provider, gias_school, site_code: "K") }

    it "copies it, because the target provider still has the school" do
      copy_schools

      expect(new_course.schools.reload.pluck(:provider_school_id)).to eq([new_provider_school.id])
    end
  end
end
