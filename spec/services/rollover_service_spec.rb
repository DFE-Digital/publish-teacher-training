require "rails_helper"

describe RolloverService do
  let!(:next_recruitment_cycle) { find_or_create :recruitment_cycle, :next }
  let(:email) { "user@education.gov.uk" }
  let(:published_course)              { build :course, enrichments: [published_course_enrichment] }
  let(:published_course_enrichment)   { build :course_enrichment, :published }
  let(:withdrawn_course)              { build :course, enrichments: [withdrawn_course_enrichment] }
  let(:withdrawn_course_enrichment)   { build :course_enrichment, :withdrawn }
  let(:rolled_over_course)                   { build :course, enrichments: [rolled_over_course_enrichment] }
  let(:rolled_over_course_enrichment)        { build :course_enrichment, :rolled_over }
  let(:initial_draft_course)                 { build :course, enrichments: [initial_draft_course_enrichment] }
  let(:initial_draft_course_enrichment)      { build :course_enrichment, :initial_draft }
  let(:subsequent_draft_course)              { build :course, enrichments: [subsequent_draft_course_enrichment] }
  let(:subsequent_draft_course_enrichment)   { build :course_enrichment, :subsequent_draft }
  let(:site) { build :site }

  let!(:site_status) do
    create :site_status,
           :published,
           :with_no_vacancies,
           course: published_course,
           site: site
  end

  let(:current_cycle_provider) do
    create :provider,
           courses: [published_course],
           sites: [site]
  end

  before do
    perform_rollover
  end

  subject(:next_cycle_provider) do
    next_recruitment_cycle.providers.find_by(
      provider_code: current_cycle_provider.provider_code,
    )
  end

  let(:new_published_course) do
    next_cycle_provider.courses.find_by(
      course_code: published_course.course_code,
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

  it "copies the published course" do
    expect(new_published_course).not_to be_nil
    expect(new_published_course).not_to eq published_course
  end

  it "copies the course enrichments" do
    expect(new_published_course.enrichments.count).to eq 1
    expect(new_published_course.enrichments.first).to be_rolled_over
  end

  it "copies the course's site" do
    new_site = next_cycle_provider.sites.find_by(code: site.code)
    expect(new_published_course.sites).to eq [new_site]
    expect(new_published_course.site_statuses.first).to be_full_time_vacancies
    expect(new_published_course.site_statuses.first).to be_status_new_status
  end

  context "when provider already rolled over" do
    it "copies a new published course" do
      course2 = create(:course, provider: current_cycle_provider, enrichments: [build(:course_enrichment, :published)])
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

  context "when provider has 1 published, 1 withdrawn and 1 rolled_over course" do
    let(:current_cycle_provider) do
      create :provider,
             courses: [published_course, withdrawn_course, rolled_over_course],
             sites: [site]
    end

    let(:new_withdrawn_course) do
      next_cycle_provider.courses.find_by(
        course_code: withdrawn_course.course_code,
      )
    end

    let(:new_rolled_over_course) do
      next_cycle_provider.courses.find_by(
        course_code: rolled_over_course.course_code,
      )
    end

    it "onlies rollover published and withdrawn courses" do
      expect(current_cycle_provider.rollable?).to eq(true)
      expect(next_cycle_provider.courses.count).to eq(2)
      expect(new_withdrawn_course).not_to be_nil
      expect(new_published_course).not_to be_nil
      expect(new_withdrawn_course).not_to eq withdrawn_course
      expect(new_published_course).not_to eq published_course
      expect(new_rolled_over_course).to be_nil
      expect(Course.all.count).to eq(5)
      expect(next_cycle_provider.rollable?).to eq(false)
      rollover_again
      expect(Course.all.count).to eq(5)
    end
  end

  context "provider with only non rollable courses" do
    let(:current_cycle_provider) do
      create :provider,
             courses: [rolled_over_course, initial_draft_course, subsequent_draft_course],
             sites: [site]
    end

    it "does not copy the provider" do
      expect(current_cycle_provider.rollable?).to eq(false)
      expect(next_cycle_provider).to be_nil
    end
  end

  context "provider with no courses" do
    let(:current_cycle_provider) do
      create :provider
    end

    it "does not copy the provider" do
      expect(current_cycle_provider.rollable?).to eq(false)
      expect(next_cycle_provider).to be_nil
    end
  end

  context "provider who accredits courses but has no courses of their own" do
    let(:current_cycle_provider) do
      create :provider,
             :accredited_body,
             accredited_courses: [published_course],
             sites: [site]
    end

    it "copies the provider" do
      expect(current_cycle_provider.rollable?).to eq(true)
      expect(next_cycle_provider).to_not be_nil
    end
  end

  context "accredited_body with 2 rollable courses" do
    let(:current_cycle_provider) do
      create :provider,
             :accredited_body,
             courses: [published_course, withdrawn_course, rolled_over_course],
             accredited_courses: [published_course],
             sites: [site]
    end

    it "copies the rollable courses" do
      expect(current_cycle_provider.rollable?).to eq(true)
      expect(next_cycle_provider.courses.count).to eq(2)
    end
  end

  def perform_rollover
    stderr = nil
    output = with_stubbed_stdout(stderr: stderr) do
      RolloverService.call(provider_codes: [current_cycle_provider.provider_code])
    end
    [output, stderr]
  end

  def rollover_again
    perform_rollover
  end
end
