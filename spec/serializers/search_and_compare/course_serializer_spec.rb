require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  let(:course) { create :course }

  describe 'json output' do
    let(:resource) { serialize(course, serializer_class: described_class) }

    subject { resource }
    context 'an existing course' do
      let(:course_factory_args) do
        {
          name: expected_json[:Name],
          course_code: expected_json[:ProgrammeCode],
          start_date: expected_json[:StartDate],
        }
      end

      let(:course) do
        create :course, **course_factory_args
      end
      let(:expected_json) do
        file = File.read("#{Dir.pwd}/spec/serializers/search_and_compare/test_data.json")
        HashWithIndifferentAccess.new(JSON.parse(file))
      end


      describe 'Course_default_value_Mapping' do
        it { should include(Id: 0) }
        it { should include(ProviderCodeName: nil) }
        it { should include(ProviderId: 0) }
        it { should include(AccreditingProviderId: nil) }
        it { should include(AgeRange: 0) }
        it { should include(RouteId: 0) }
        it { should include(ProviderLocationId: nil) }
        it { should include(Distance: nil) }
        it { should include(DistanceAddress: nil) }
        it { should include(ContactDetailsId: nil) }
      end

      describe 'Course_direct_Mapping' do
        it { should include(Name: course.name) }
        it { should include(ProgrammeCode: course.course_code) }
        it { should include(StartDate: course.start_date) }
      end

      # should work fine once hardcoded/db ones are flushed out
      xit { should eq expected_json }
    end
  end
end
