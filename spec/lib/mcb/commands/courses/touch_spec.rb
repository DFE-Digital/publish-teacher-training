require 'mcb_helper'

describe '"mcb courses touch"' do
  let(:course)   { create :course, updated_at: 1.day.ago, changed_at: 1.day.ago }
  let(:provider) { course.provider }

  it 'updates the courses updated_at' do
    Timecop.freeze do
      with_stubbed_stdout do
        $mcb.run(%W[course touch #{provider.provider_code} #{course.course_code}])
      end

      expect(course.reload.updated_at).to eq Time.now
    end
  end

  it 'updates the courses changed_at' do
    Timecop.freeze do
      with_stubbed_stdout do
        $mcb.run(%W[course touch #{provider.provider_code} #{course.course_code}])
      end

      expect(course.reload.changed_at).to eq Time.now
    end
  end

  it 'adds audit comment' do
    expect {
      with_stubbed_stdout do
        $mcb.run(%W[course touch #{provider.provider_code} #{course.course_code}])
      end
    }.to change { course.reload.audits.count }
           .from(1).to(2)
  end
end
