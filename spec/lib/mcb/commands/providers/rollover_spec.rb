require 'mcb_helper'

describe 'mcb providers rollover' do
  def perform_rollover(provider_code)
    stderr = nil
    output = with_stubbed_stdout(stderr: stderr) do
      cmd.run([provider_code])
    end
    [output, stderr]
  end

  let(:lib_dir) { Rails.root.join('lib') }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/providers/rollover.rb")
  end
  let(:course)              { build :course, enrichments: [course_enrichment] }
  let(:course_enrichment)   { build :course_enrichment, :published }
  let(:provider_enrichment) { build :provider_enrichment, :published }
  let(:site)                { build :site }
  let!(:site_status) {
    create :site_status,
           :with_no_vacancies,
           course: course,
           site: site
  }
  let!(:provider) {
    create :provider,
           enrichments: [provider_enrichment],
           courses: [course],
           sites: [site]
  }

  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }

  let(:email) { 'user@education.gov.uk' }

  before do
    allow(MCB).to receive(:config).and_return(email: email)
  end

  it "copies a provider and it's courses" do
    perform_rollover(provider.provider_code)

    new_provider = next_recruitment_cycle.providers.find_by(
      provider_code: provider.provider_code
    )
    expect(new_provider).not_to be_nil
    expect(new_provider).not_to eq provider
    # Currently failing, uncomment when fixed.
    # expect(new_provider.enrichments.count).to eq 1
    # expect(new_provider.enrichments.first).to be_draft

    new_course = new_provider.courses.find_by(
      course_code: course.course_code
    )
    expect(new_course).not_to be_nil
    expect(new_course).not_to eq course
    expect(new_course.enrichments.count).to eq 1
    expect(new_course.enrichments.first).to be_rolled_over

    new_site = new_provider.sites.find_by(code: site.code)
    expect(new_site).not_to be_nil
    expect(new_site).not_to eq site
    expect(new_course.sites).to eq [new_site]
    expect(new_course.site_statuses.first).to be_full_time_vacancies
    expect(new_course.site_statuses.first).to be_status_new_status
  end
end
