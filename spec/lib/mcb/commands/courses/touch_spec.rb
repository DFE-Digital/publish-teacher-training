require 'mcb_helper'

describe 'mcb courses touch', :focus do
  let(:recruitment_year1) { create :recruitment_cycle, year: '2018' }
  let(:recruitment_year2) { RecruitmentCycle.current_recruitment_cycle }

  let(:provider) { create :provider, updated_at: 1.day.ago, changed_at: 1.day.ago, recruitment_cycle: recruitment_year1 }
  let(:rolled_over_provider) do
    new_provider = provider.dup
    new_provider.update(recruitment_cycle: recruitment_year2)
    new_provider.save
    new_provider
  end

  let(:course) { create :course, updated_at: 1.day.ago, changed_at: 1.day.ago, provider: provider }
  let(:rolled_over_course) do
    new_course = course.dup
    new_course.update(provider: rolled_over_provider)
    new_course.save
    new_course
  end

  context 'when the recruitment year is unspecified' do
    it 'updates the course updated_at for the current recruitment cycle' do
      rolled_over_course

      Timecop.freeze(Date.today + 1) do
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{rolled_over_provider.provider_code} #{rolled_over_course.course_code}])
        end

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(rolled_over_course.reload.updated_at.to_i).to eq Time.now.to_i
        expect(course.reload.updated_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'updates the course changed_at' do
      rolled_over_course

      Timecop.freeze(Date.today + 1) do
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{rolled_over_provider.provider_code} #{rolled_over_course.course_code}])
        end

        expect(rolled_over_course.reload.changed_at.to_i).to eq Time.now.to_i
        expect(course.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'adds audit comment' do
      rolled_over_course

      expect {
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{rolled_over_provider.provider_code} #{rolled_over_course.course_code}])
        end
      }.to change { rolled_over_course.reload.audits.count }
             .from(1).to(2)
    end
  end

  context 'when the recruitment year is specified' do
    it 'updates the course updated_at' do
      rolled_over_course

      Timecop.freeze(Date.today + 1) do
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{provider.provider_code} #{course.course_code} -r 2018])
        end

        # Use to_i compare seconds since epoch and side-step sub-second
        # differences that show up even with Timecop on certain platforms.
        expect(course.reload.updated_at.to_i).to eq Time.now.to_i
        expect(rolled_over_course.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'updates the courses changed_at' do
      rolled_over_course

      Timecop.freeze(Date.today + 1) do
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{provider.provider_code} #{course.course_code} -r 2018])
        end

        expect(course.reload.changed_at.to_i).to eq Time.now.to_i
        expect(rolled_over_course.reload.changed_at.to_i).not_to eq Time.now.to_i
      end
    end

    it 'adds audit comment' do
      rolled_over_course

      expect {
        with_stubbed_stdout do
          $mcb.run(%W[courses touch #{provider.provider_code} #{course.course_code} -r 2018])
        end
      }.to change { course.reload.audits.count }
             .from(1).to(2)
    end
  end
end
