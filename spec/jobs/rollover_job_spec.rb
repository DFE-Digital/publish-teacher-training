# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe RolloverJob do
  let(:recruitment_cycle) { create(:recruitment_cycle) }
  let!(:providers) { create_list(:provider, 15, recruitment_cycle: recruitment_cycle) }

  before do
    allow(RecruitmentCycle).to receive(:current_recruitment_cycle).and_return(recruitment_cycle)
    Sidekiq::Testing.fake!
  end

  after { Sidekiq::Testing.disable! }

  describe "#perform" do
    it "enqueues jobs with correct staggered timings" do
      Timecop.freeze do
        current_time = Time.zone.now
        subject.perform

        expect(Sidekiq::Queues["default"].size).to eq(15)

        providers[0..9].each do |provider|
          job = find_job(provider.provider_code)

          expect(job).to include(
            "class" => "RolloverProviderJob",
            "args" => [provider.provider_code],
            "enqueued_at" => current_time.to_f,
          )
        end

        providers[10..14].each do |provider|
          job = find_job(provider.provider_code)

          expect(job).to include(
            "class" => "RolloverProviderJob",
            "args" => [provider.provider_code],
            "at" => (current_time + 1.hour).to_f,
          )
        end
      end
    end

    it "handles empty provider lists gracefully" do
      Provider.delete_all
      expect { subject.perform }.not_to change(Sidekiq::Queues["default"], :size)
    end
  end

  def find_job(provider_code)
    Sidekiq::Queues["default"].find { |j| j["args"] == [provider_code] }
  end
end
