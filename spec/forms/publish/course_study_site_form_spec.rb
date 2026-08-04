# frozen_string_literal: true

require "rails_helper"

module Publish
  RSpec.describe CourseStudySiteForm do
    let(:provider) { create(:provider, study_sites: [study_site_one, study_site_two]) }
    let(:study_site_one) { build(:site, :study_site, location_name: "Study site 1") }
    let(:study_site_two) { build(:site, :study_site, location_name: "Study site 2") }
    let(:course) { create(:course, :published, provider:, study_sites: [study_site_one]) }
    let(:previous_timestamp) { 1.day.ago.change(usec: 0) }

    before do
      course.enrichments.published.update_all(last_published_timestamp_utc: previous_timestamp)
    end

    describe "#save!" do
      it "refreshes last_published_at when study sites change" do
        form = described_class.new(course, params: { study_site_ids: [study_site_one.id, study_site_two.id] })

        expect(form.save!).to be(true)
        expect(course.reload.last_published_at).to be_within(5.seconds).of(Time.zone.now)
        expect(course.last_published_at).to be > previous_timestamp
      end

      it "does not refresh last_published_at when study sites are unchanged" do
        form = described_class.new(course, params: { study_site_ids: ["", study_site_one.id.to_s] })

        expect(form.save!).to be(true)
        expect(course.reload.last_published_at).to eq(previous_timestamp)
      end
    end
  end
end
