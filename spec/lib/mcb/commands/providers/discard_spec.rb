require "mcb_helper"

describe "mcb providers discard" do
  def execute_discard_provider(arguments: [])
    $mcb.run(["providers", "discard", *arguments])
  end

  let(:provider) { create(:provider, recruitment_cycle: recruitment_cycle, courses: [course]) }
  let(:provider2)  { create(:provider, recruitment_cycle: next_recruitment_cycle, courses: [course2], provider_code: provider.provider_code) }
  let(:course) { build(:course) }
  let(:course2) { build(:course) }
  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }


  context "for the current recruitment cycle" do
    before do
      provider
      provider2
      execute_discard_provider(arguments: [provider.provider_code, "-r", recruitment_cycle.year])
    end

    it "discards the provider" do
      expect(provider.reload.discarded?).to be_truthy
      expect(provider.reload.discarded_at).to be_within(1.second).of Time.now.utc
      expect(course.reload.discarded?).to be_truthy
      expect(course.discarded_at).to be_within(1.second).of Time.now.utc
      expect(provider2.reload.discarded?).to be_falsey
      expect(provider2.courses.first.reload.discarded?).to be_falsey
    end
  end

  context "for the next recruitment cycle" do
    before do
      provider
      provider2
      execute_discard_provider(arguments: [provider.provider_code, "-r", next_recruitment_cycle.year])
    end

    it "discards the provider" do
      expect(provider2.reload.discarded?).to be_truthy
      expect(provider2.reload.discarded_at).to be_within(1.second).of Time.now.utc
      expect(course2.reload.discarded?).to be_truthy
      expect(course2.reload.discarded_at).to be_within(1.second).of Time.now.utc
      expect(provider.reload.discarded?).to be_falsey
      expect(provider.courses.first.reload.discarded?).to be_falsey
    end
  end

  context "with no recruitment)_cycle passedin" do
    before do
      provider
      provider2
      execute_discard_provider(arguments: [provider.provider_code])
    end

    it "default to the currecnt cycle and discards the provider" do
      expect(provider.reload.discarded?).to be_truthy
      expect(provider.reload.discarded_at).to be_within(1.second).of Time.now.utc
      expect(provider2.reload.discarded?).to be_falsey
    end
  end
end
