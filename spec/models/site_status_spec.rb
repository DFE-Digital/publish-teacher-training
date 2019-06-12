# == Schema Information
#
# Table name: course_site
#
#  id                         :integer          not null, primary key
#  applications_accepted_from :date
#  course_id                  :integer
#  publish                    :text
#  site_id                    :integer
#  status                     :text
#  vac_status                 :text
#
require 'rails_helper'


RSpec.describe SiteStatus, type: :model do
  it_behaves_like 'Touch course', :site_status

  RSpec::Matchers.define :be_findable do
    match do |actual|
      SiteStatus.findable.include?(actual)
    end
  end

  RSpec::Matchers.define :be_open_for_applications do
    match do |actual|
      SiteStatus.open_for_applications.include?(actual)
    end
  end

  RSpec::Matchers.define :have_vacancies do
    match do |actual|
      SiteStatus.with_vacancies.include?(actual)
    end
  end

  describe 'auditing' do
    it { should be_audited.associated_with(:course) }
  end

  describe 'creation' do
    context 'when course has a running site' do
      let(:provider)    { build(:provider) }
      let(:site1)       { build(:site, provider: provider) }
      let(:site2)       { build(:site, provider: provider) }
      let(:site_status) { build(:site_status, :running, site: site1) }
      let(:course) do
        create(:course, provider: provider, site_statuses: [site_status])
      end

      before do
        site_status
        expect(course.reload.ucas_status).not_to be(:new)
      end

      describe 'the status' do
        it 'is set to running' do
          new_site_status = SiteStatus.create course: course, site: site2

          expect(new_site_status).to be_status_running
        end

        context 'when using the course association' do
          it 'is set to running' do
            course.sites << site2

            new_site_status = course.site_statuses.last
            expect(new_site_status).to be_status_running
          end
        end
      end
    end

    context 'when course has a new site' do
      let(:site1)       { create(:site) }
      let(:course)      { create(:course) }
      let(:site_status) { create(:site_status, :new, site: site1, course: course) }
      let(:site2)       { create(:site) }

      before do
        site_status
        expect(course.reload.ucas_status).to be(:new)
      end

      describe 'the status' do
        it 'is set to new' do
          new_site_status = SiteStatus.create course: course, site: site2

          expect(new_site_status).to be_status_new_status
        end

        describe 'when using the course association' do
          it 'is set to new' do
            course.sites << site2

            site_status2 = course.site_statuses.last
            expect(site_status2).to be_status_new_status
          end
        end
      end
    end

    context 'when course has no sites' do
      let(:course) { create(:course) }
      let(:site2)  { create(:site) }

      before do
        expect(course.reload.ucas_status).to be(:new)
      end

      describe 'the status' do
        it 'is set to new' do
          new_site_status = SiteStatus.create course: course, site: site2

          expect(new_site_status).to be_status_new_status
        end

        describe 'when using the course association' do
          it 'is set to new' do
            course.sites << site2

            site_status2 = course.site_statuses.last
            expect(site_status2).to be_status_new_status
          end
        end
      end
    end
  end

  describe 'destruction' do
    let(:site1)        { create(:site) }
    let(:site2)        { create(:site) }
    let(:course)       { create(:course) }
    let(:site_status1) { create(:site_status, state, site: site1, course: course) }
    let(:site_status2) { create(:site_status, state, site: site2, course: course) }

    context 'when course has running sites' do
      let(:state) { :running }

      before do
        site_status1
        site_status2
      end

      describe 'the record' do
        it 'is set to suspended' do
          expect(course.reload.ucas_status).not_to be(:new)

          site_status2.destroy

          expect(site_status2.reload).to be_status_suspended
        end
      end

      describe 'using courses association' do
        it 'it is suspended' do
          expect(course.reload.ucas_status).not_to be(:new)

          course.sites = [site1]

          expect(site_status2.reload).to be_status_suspended
        end
      end
    end

    context 'when course has new sites' do
      let(:state) { :new }

      before do
        site_status1
        site_status2
      end

      describe 'the record' do
        it 'is destroyed' do
          expect(course.reload.ucas_status).to be(:new)

          site_status2.destroy

          expect(SiteStatus.exists?(site_status2.id)).to be_falsey
        end
      end

      describe 'using courses association' do
        it 'it is destroyed' do
          expect(course.reload.ucas_status).to be(:new)

          course.sites = [site1]

          expect(SiteStatus.exists?(site_status2.id)).to be_falsey
        end
      end
    end
  end

  describe 'associations' do
    subject { build(:site_status) }

    it { should belong_to(:site) }
    it { should belong_to(:course) }
  end

  describe 'is it on find?' do
    describe 'if discontinued on UCAS' do
      subject { create(:site_status, :discontinued) }
      it { should_not be_findable }
    end

    describe 'if suspended on UCAS' do
      subject { create(:site_status, :suspended) }
      it { should_not be_findable }
    end

    describe 'if new on UCAS' do
      subject { create(:site_status, :new) }
      it { should_not be_findable }
    end

    describe 'if running but not published on UCAS' do
      subject { create(:site_status, :running, :unpublished) }
      it { should_not be_findable }
    end

    describe 'if running and published on UCAS' do
      subject { create(:site_status, :running, :published) }
      it { should be_findable }
    end
  end

  describe 'applications open?' do
    describe 'if on find, application date open and has full-time vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :full_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if on find, application date open and has part-time vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :part_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if on find, application date open and has both full-time and part-time vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :both_full_time_and_part_time_vacancies) }
      it { should be_open_for_applications }
    end

    describe 'if not on find' do
      subject { create(:site_status, :suspended) }
      it { should_not be_open_for_applications }
    end

    describe 'if on find but applications accepted in the future' do
      subject { create(:site_status, :findable, :applications_being_accepted_in_future) }
      it { should_not be_open_for_applications }
    end

    describe 'if on find, applications accepted now but no vacancies' do
      subject { create(:site_status, :findable, :applications_being_accepted_now, :with_no_vacancies) }
      it { should_not be_open_for_applications }
    end
  end

  describe "has vacancies?" do
    describe 'if has part-time vacancies' do
      subject { create(:site_status, :part_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has full-time vacancies' do
      subject { create(:site_status, :full_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has both full-time and part-time vacancies' do
      subject { create(:site_status, :both_full_time_and_part_time_vacancies) }
      it { should have_vacancies }
    end

    describe 'if has no vacancies' do
      subject { create(:site_status, :with_no_vacancies) }
      it { should_not have_vacancies }
    end
  end

  describe "vac_status" do
    specs = [
      {
        course_study_mode: :full_time,
        valid_states: %w[no_vacancies full_time_vacancies],
        invalid_states: %w[part_time_vacancies both_full_time_and_part_time_vacancies]
      },
      {
        course_study_mode: :part_time,
        valid_states: %w[no_vacancies part_time_vacancies],
        invalid_states: %w[full_time_vacancies both_full_time_and_part_time_vacancies]
      },
      {
        course_study_mode: :full_time_or_part_time,
        valid_states: %w[no_vacancies part_time_vacancies full_time_vacancies both_full_time_and_part_time_vacancies],
        invalid_states: []
      },
    ].freeze

    specs.each do |spec|
      context "#{spec[:study_mode].to_s.humanize(capitalize: false)} course" do
        let(:course) { build(:course, study_mode: spec[:course_study_mode]) }

        spec[:valid_states].each do |state|
          context "vac_status set to #{state}" do
            subject { build(:site_status, vac_status: state, course: course) }
            it { should be_valid }
          end
        end

        spec[:invalid_states].each do |state|
          context "vac_status set to #{state}" do
            subject { build(:site_status, vac_status: state, course: course) }
            it { should_not be_valid }

            it 'has a validation error about vacancy status not matching study mode' do
              subject.valid?
              expect(subject.errors.full_messages).to include("Vac status (#{state}) must be consistent with course study mode #{course.study_mode}")
            end
          end
        end
      end
    end
  end

  describe "description" do
    subject { build(:site_status, :running, :unpublished, site: create(:site, location_name: 'Foo', code: '1')) }
    its(:description) { should eq 'Foo (code: 1) – running/unpublished' }
  end

  describe "default_vac_status_given" do
    subject { SiteStatus }
    it "should return correct default_vac_status" do
      expect(subject.default_vac_status_given(study_mode: 'full_time')).to eq :full_time_vacancies
      expect(subject.default_vac_status_given(study_mode: 'part_time')).to eq :part_time_vacancies
      expect(subject.default_vac_status_given(study_mode: 'full_time_or_part_time')).to eq :both_full_time_and_part_time_vacancies
      expect { subject.default_vac_status_given(study_mode: 'foo') }.to raise_error("Unexpected study mode foo")
    end
  end

  describe "status changes" do
    describe "when suspending a running, published site status" do
      subject { create(:site_status, :running, :published).tap(&:suspend!).reload }
      it { should be_status_suspended }
      it { should be_unpublished_on_ucas }
    end

    %i[new suspended discontinued].each do |status|
      describe "when starting a #{status}, unpublished site status" do
        subject { create(:site_status, status, :unpublished).tap(&:start!).reload }
        it { should be_status_running }
        it { should be_published_on_ucas }
      end
    end
  end
end
