# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rollover::Schools::DualCourseCopier do
  subject(:copier) { described_class.new(legacy_copier:, new_copier:) }

  let(:legacy_copier) { instance_double(Rollover::Schools::LegacyCourseCopier, call: nil) }
  let(:new_copier) { instance_double(Rollover::Schools::CourseCopier, call: nil) }
  let(:course) { build_stubbed(:course) }
  let(:new_provider) { build_stubbed(:provider) }
  let(:new_course) { build_stubbed(:course, provider: new_provider) }

  it "copies both legacy site statuses and new course-school relationships" do
    copier.call(course:, new_provider:, new_course:)

    expect(legacy_copier).to have_received(:call).with(course:, new_provider:, new_course:)
    expect(new_copier).to have_received(:call).with(course:, new_provider:, new_course:)
  end
end
