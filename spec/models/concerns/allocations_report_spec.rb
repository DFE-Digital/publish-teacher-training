require "rails_helper"

describe Course do
  let(:subjects) { [create(:subject, :primary), create(:subject, :english)] }
  let(:course) { create :course, subjects: subjects }

  describe '#allocations_report_data' do
    subject { Course.where(id: course.id).allocations_report_data }

    it 'returns the headers' do
      expect(subject.first).to eq Course.allocations_report_headers
    end

    it 'returns the field data' do
      expect(subject.last)
        .to eq course.allocations_report_fields.flatten
    end
  end

  describe '#allocations_report_fields' do
    subject { course.allocations_report_fields.flatten }

    its([0]) { should eq '2020/21' }
    its([1]) { should be_nil }
    its([3]) { should eq course.provider.provider_name }

    context 'course has an accrediting provider' do
      let(:accrediting_provider) { create :provider, :accredited_body }
      let(:course) do
        create(:course,
               accrediting_provider: accrediting_provider,
               subjects: subjects)
      end

      its([1]) { should eq accrediting_provider.provider_name }
    end
  end
end
