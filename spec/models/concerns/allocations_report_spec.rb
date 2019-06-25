require "rails_helper"

describe Course do
  let(:subjects) { [create(:subject, :primary), create(:subject, :english)] }
  let(:course) { create :course, subjects: subjects }

  xdescribe '#allocations_report_data' do
    subject { Course.where(id: course.id).allocations_report_data }

    it 'returns the headers' do
      expect(subject.first).to eq Course.allocations_report_headers
    end

    it 'returns the field data' do
      expect(subject.last)
        .to eq course.allocations_report_fields.flatten
    end

    context 'a course whose provider has no organisation' do
      let(:provider) { create :provider, organisations: [] }
      let(:course) { create :course, provider: provider, subjects: subjects }

      it 'is not included in the output' do
        expect(subject[1..]).to be_empty
      end
    end
  end

  xdescribe '#allocations_report_fields' do
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
