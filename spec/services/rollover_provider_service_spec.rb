# frozen_string_literal: true

require "rails_helper"

describe RolloverProviderService do
  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  let(:copy_course_to_provider_service) { instance_double(Courses::CopyToProviderService) }
  let(:copy_provider_to_recruitment_cycle_service) { instance_double(Providers::CopyToRecruitmentCycleService) }

  before do
    allow(Courses::CopyToProviderService).to receive(:new).with(
      sites_copy_to_course: Sites::CopyToCourseService,
      enrichments_copy_to_course: instance_of(Enrichments::CopyToCourseService),
      force:,
    ).and_return(copy_course_to_provider_service)

    allow(Providers::CopyToRecruitmentCycleService).to receive(:new).with(
      copy_course_to_provider_service:,
      copy_site_to_provider_service: instance_of(Sites::CopyToProviderService),
      copy_partnership_to_provider_service: instance_of(Partnerships::CopyToProviderService),
      force:,
    ).and_return(copy_provider_to_recruitment_cycle_service)
  end

  describe ".call" do
    let(:force) { false }
    let(:course_codes) { %w[B05S] }
    let(:provider) { create(:provider, provider_code: "AB1") }

    before do
      provider

      allow(copy_provider_to_recruitment_cycle_service).to receive(:execute).and_return(
        {
          providers: 0,
          sites: 0,
          courses: 0,
        },
      )
    end

    it "passes the correct arguments down to the `CopyToRecruitmentCycle` service" do
      expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
        provider:, new_recruitment_cycle: next_recruitment_cycle, course_codes:,
      )

      described_class.call(provider_code: provider.provider_code, course_codes:, force:)
    end

    context "when a new_recruitment_cycle_id is provided" do
      let(:custom_recruitment_cycle) do
        find_or_create(
          :recruitment_cycle,
          year: 1.year.from_now.year,
          application_start_date: Time.zone.local(Date.current.year.to_i + 1, 10, 1),
          application_end_date: Time.zone.local(Date.current.year.to_i + 2, 9, 30),
        )
      end

      it "uses the specified recruitment cycle" do
        expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
          provider:, new_recruitment_cycle: custom_recruitment_cycle, course_codes:,
        )

        described_class.call(
          provider_code: provider.provider_code,
          course_codes: course_codes,
          force: force,
          new_recruitment_cycle_id: custom_recruitment_cycle.id,
        )
      end
    end
  end
end
