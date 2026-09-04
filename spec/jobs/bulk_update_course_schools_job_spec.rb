# frozen_string_literal: true

require "rails_helper"

describe BulkUpdateCourseSchoolsJob do
  let(:provider) { create(:provider) }
  let(:course) { create(:course, provider:, sites: []) }
  let(:relation) { instance_double(ActiveRecord::Relation) }

  it "applies the change to the courses it was given" do
    allow(Publish::Schools::BulkUpdate::Apply).to receive(:call)

    described_class.new.perform([course.id], %w[added], %w[removed])

    expect(Publish::Schools::BulkUpdate::Apply).to have_received(:call) do |courses:, added_uuids:, removed_uuids:|
      expect(courses).to contain_exactly(course)
      expect(added_uuids).to eq(%w[added])
      expect(removed_uuids).to eq(%w[removed])
    end
  end

  it "ignores a course that was deleted while the job was waiting" do
    allow(Publish::Schools::BulkUpdate::Apply).to receive(:call)

    described_class.new.perform([course.id, course.id + 1_000], [], [])

    expect(Publish::Schools::BulkUpdate::Apply).to have_received(:call) do |courses:, **|
      expect(courses).to contain_exactly(course)
    end
  end
end
