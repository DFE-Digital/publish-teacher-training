require "mcb_helper"

describe "mcb providers rollover" do
  let(:lib_dir) { Rails.root.join("lib") }
  let(:cmd) do
    Cri::Command.load_file("#{lib_dir}/mcb/commands/providers/rollover.rb")
  end

  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }
  let(:email) { "user@education.gov.uk" }
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

  let(:current_cycle_provider) {
    create :provider,
           enrichments: [provider_enrichment],
           courses: [course],
           sites: [site]
  }

  before do
    perform_rollover
  end

  subject(:next_cycle_provider) do
    next_recruitment_cycle.providers.find_by(
      provider_code: current_cycle_provider.provider_code,
    )
  end

  let(:new_course) do
    next_cycle_provider.courses.find_by(
      course_code: course.course_code,
    )
  end

  it "copies the provider" do
    expect(next_cycle_provider).not_to be_nil
    expect(next_cycle_provider).not_to eq current_cycle_provider
  end

  it "copies the provider's site" do
    new_site = next_cycle_provider.sites.find_by(code: site.code)
    expect(new_site).not_to be_nil
    expect(new_site).not_to eq site
  end

  it "copies the course" do
    expect(new_course).not_to be_nil
    expect(new_course).not_to eq course
  end

  it "copies the course enrichments" do
    expect(new_course.enrichments.count).to eq 1
    expect(new_course.enrichments.first).to be_rolled_over
  end

  it "copies the course's site" do
    new_site = next_cycle_provider.sites.find_by(code: site.code)
    expect(new_course.sites).to eq [new_site]
    expect(new_course.site_statuses.first).to be_full_time_vacancies
    expect(new_course.site_statuses.first).to be_status_new_status
  end

  xit "copies the provider enrichments" do
    # todo: ?? Currently failing, uncomment when fixed.
    expect(next_cycle_provider.enrichments.count).to eq 1
    expect(next_cycle_provider.enrichments.first).to be_draft
  end

  context "when provider already rolled over" do
    it "copies a new course" do
      course2 = create(:course, provider: current_cycle_provider)
      current_cycle_provider.courses.reload

      rollover_again

      duplicated_course2 = next_cycle_provider.courses.find_by(course_code: course2.course_code)
      expect(duplicated_course2).not_to be_nil
      expect(duplicated_course2).not_to eq(course2)
      expect(next_cycle_provider.courses.length).to eq(current_cycle_provider.courses.length)
    end

    it "copies a new site" do
      site2 = create(:site, provider: current_cycle_provider)
      current_cycle_provider.sites.reload

      rollover_again

      duplicated_site2 = next_cycle_provider.sites.find_by(code: site2.code)
      expect(duplicated_site2).not_to be_nil
      expect(duplicated_site2).not_to eq(site2)
      expect(next_cycle_provider.sites.length).to eq(current_cycle_provider.sites.length)
    end
  end

  def perform_rollover
    stderr = nil
    output = with_stubbed_stdout(stderr: stderr) do
      cmd.run([current_cycle_provider.provider_code])
    end
    [output, stderr]
  end

  def rollover_again
    perform_rollover
  end
end
