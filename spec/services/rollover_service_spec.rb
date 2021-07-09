require "rails_helper"

describe RolloverService do
  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  let(:copy_course_to_provider_service) { instance_double(Courses::CopyToProviderService) }
  let(:copy_provider_to_recruitment_cycle_service) { instance_double(Providers::CopyToRecruitmentCycleService) }

  before do
    allow(Courses::CopyToProviderService).to receive(:new).with(
      sites_copy_to_course: instance_of(Sites::CopyToCourseService),
      enrichments_copy_to_course: instance_of(Enrichments::CopyToCourseService),
    ).and_return(copy_course_to_provider_service)

    allow(Providers::CopyToRecruitmentCycleService).to receive(:new).with(
      copy_course_to_provider_service: copy_course_to_provider_service,
      copy_site_to_provider_service: instance_of(Sites::CopyToProviderService),
      logger: instance_of(Logger),
    ).and_return(copy_provider_to_recruitment_cycle_service)
  end

  describe ".call" do
    context "with provider codes" do
      let(:provider) { create(:provider, provider_code: "AB1") }
      let(:provider_to_ignore) { create(:provider, provider_code: "CD2") }

      before do
        provider
        provider_to_ignore

        allow(copy_provider_to_recruitment_cycle_service).to receive(:execute).and_return(
          {
            providers: 0,
            sites: 0,
            courses: 0,
          },
        )
      end

      it "passes the providers in provider_codes to the `CopyToRecruitmentCycle` service" do
        expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
          provider: provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
        )

        no_output { described_class.call(provider_codes: ["AB1"]) }
      end

      it "doesn't pass other providers" do
        expect(copy_provider_to_recruitment_cycle_service).not_to receive(:execute).with(
          provider: provider_to_ignore, new_recruitment_cycle: next_recruitment_cycle, force: false,
        )

        no_output { described_class.call(provider_codes: ["AB1"]) }
      end

      context "when providers exist in other cycles" do
        let(:previous_cycle) { create(:recruitment_cycle, :previous) }
        let(:past_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "AB1") }
        let(:future_provider) { create(:provider, recruitment_cycle: next_recruitment_cycle) }

        it "doesn't pass other providers" do
          expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
            provider: provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          expect(copy_provider_to_recruitment_cycle_service).not_to receive(:execute).with(
            provider: past_provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          expect(copy_provider_to_recruitment_cycle_service).not_to receive(:execute).with(
            provider: future_provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          no_output { described_class.call(provider_codes: ["AB1"]) }
        end
      end
    end

    context "without provider codes" do
      let(:provider) { create(:provider, provider_code: "AB1") }
      let(:other_provider) { create(:provider, provider_code: "CD2") }

      before do
        provider
        other_provider

        allow(copy_provider_to_recruitment_cycle_service).to receive(:execute).and_return(
          {
            providers: 0,
            sites: 0,
            courses: 0,
          },
        )
      end

      it "passes all providers `CopyToRecruitmentCycle` service" do
        expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
          provider: provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
        )
        expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
          provider: other_provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
        )

        no_output { described_class.call(provider_codes: []) }
      end

      context "when providers exist in other cycles" do
        let(:previous_cycle) { create(:recruitment_cycle, :previous) }
        let(:past_provider) { create(:provider, recruitment_cycle: previous_cycle, provider_code: "AB1") }
        let(:future_provider) { create(:provider, recruitment_cycle: next_recruitment_cycle) }

        it "doesn't pass other providers" do
          expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
            provider: provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          expect(copy_provider_to_recruitment_cycle_service).not_to receive(:execute).with(
            provider: past_provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          expect(copy_provider_to_recruitment_cycle_service).not_to receive(:execute).with(
            provider: future_provider, new_recruitment_cycle: next_recruitment_cycle, force: false,
          )

          no_output { described_class.call(provider_codes: []) }
        end
      end

      context "force: true" do
        it "passes the argument to the `CopyToRecruitmentCycle` service" do
          expect(copy_provider_to_recruitment_cycle_service).to receive(:execute).with(
            provider: provider, new_recruitment_cycle: next_recruitment_cycle, force: true,
          )

          no_output { described_class.call(provider_codes: [], force: true) }
        end
      end
    end

    def no_output(&block)
      stderr = nil
      output = with_stubbed_stdout(stderr: stderr, &block)
      [output, stderr]
    end
  end
end
