require 'mcb_helper'

describe 'mcb sites delete' do
  def delete(arguments: [], input: [])
    output = with_stubbed_stdout(stdin: input.join("\n"), stderr: nil) do
      $mcb.run(%w[sites delete] + arguments)
    end

    { stdout: output }
  end

  let(:current_recruitment_cycle) { RecruitmentCycle.current_recruitment_cycle }
  let(:rolled_over_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  let(:current_provider) { create :provider, recruitment_cycle: current_recruitment_cycle }
  let(:rolled_over_provider) do
    new_provider = current_provider.dup
    new_provider.update(recruitment_cycle: rolled_over_recruitment_cycle)
    new_provider.save
    new_provider
  end

  let(:current_site) { create :site, provider: current_provider }
  let(:rolled_over_site) do
    new_site = current_site.dup
    new_site.update(provider: rolled_over_provider)
    new_site.save
    new_site
  end

  context 'with recruitment year unspecified' do
    it 'aborts if confirmation denied' do
      rolled_over_site
      expect(delete(arguments: [current_site.code], input: %w[No])[:stdout]).to eq("Are you sure you want to delete site #{current_site.code}? \nSite not deleted\n")

      expect(Site.exists?(id: current_site.id)).to eq(true)
      expect(Site.exists?(id: rolled_over_site.id)).to eq(true)
    end

    it 'deletes the site' do
      rolled_over_site
      expect(delete(arguments: [current_site.code], input: %w[Yes])[:stdout]).to eq("Are you sure you want to delete site #{current_site.code}? \nSite deleted\n")

      expect(Site.exists?(id: current_site.id)).to eq(false)
      expect(Site.exists?(id: rolled_over_site.id)).to eq(true)
    end

    it 'errors if the site does not exist' do
      rolled_over_site
      expect(delete(arguments: %w[E], input: %w[Yes])[:stdout]).to eq("The site E does not exist\n")
    end
  end

  context 'with recruitment year specified' do
    it 'deletes the site' do
      rolled_over_site
      delete(arguments: [current_site.code, '-r', rolled_over_recruitment_cycle.year], input: %w[Yes])

      expect(Site.exists?(id: rolled_over_site.id)).to eq(false)
      expect(Site.exists?(id: current_site.id)).to eq(true)
    end
  end
end
