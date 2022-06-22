require "rails_helper"

describe RolloverProviderService do
  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  let(:copy_course_to_provider_service) { instance_double(Courses::CopyToProviderService) }
  let(:copy_provider_to_recruitment_cycle_service) { instance_double(Providers::CopyToRecruitmentCycleService) }

  before do
    allow(Courses::CopyToProviderService).to receive(:new).with(
      sites_copy_to_course: instance_of(Sites::CopyToCourseService),
      enrichments_copy_to_course: instance_of(Enrichments::CopyToCourseService),
      force: force,
    ).and_return(copy_course_to_provider_service)

    allow(Providers::CopyToRecruitmentCycleService).to receive(:new).with(
      copy_course_to_provider_service: copy_course_to_provider_service,
      copy_site_to_provider_service: instance_of(Sites::CopyToProviderService),
      force: force,
    ).and_return(copy_provider_to_recruitment_cycle_service)
  end

  describe ".call" do
    let(:force) { false }
    let(:course_codes) { ["B05S"] }
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
        provider: provider, new_recruitment_cycle: next_recruitment_cycle, course_codes: course_codes,
      )

      described_class.call(provider_code: provider.provider_code, course_codes: course_codes, force: force)
    end
  end
end
