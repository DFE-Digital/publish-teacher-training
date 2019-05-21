require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  describe 'json output' do
    let(:resource) { serialize(course, serializer_class: described_class) }

    subject { resource }

    context 'an existing course' do
      let(:course_factory_args) do
        {
          provider: provider,
          accrediting_provider: accrediting_provider,
          name: expected_json[:Name],
          course_code: expected_json[:ProgrammeCode],
          start_date: expected_json[:StartDate],
        }
      end

      let(:course) do
        create :course, **course_factory_args
      end

      let(:provider) do
        create :provider,
               provider_code: expected_json[:Provider][:ProviderCode],
               provider_name: expected_json[:Provider][:Name]
      end
      let(:accrediting_provider) do
        create :provider,
               provider_code: expected_json[:AccreditingProvider][:ProviderCode],
               provider_name: expected_json[:AccreditingProvider][:Name]
      end

      let(:expected_json) do
        file = File.read("#{Dir.pwd}/spec/serializers/search_and_compare/test_data.json")
        HashWithIndifferentAccess.new(JSON.parse(file))
      end

      describe 'Provider_serializer_Mapping' do
        # testing the provider serializer, its part of the json
        describe 'Provider' do
          subject { resource[:Provider] }
          describe 'Provider_default_value_Mapping' do
            it { should include(Id: 0) }
            it { should include(Courses: nil) }
            it { should include(AccreditedCourses: nil) }
          end
          describe 'Provider_direct_simple_Mappting' do
            it { should include(Name: provider.provider_name) }
            it { should include(ProviderCode: provider.provider_code) }
          end
        end

        describe 'AccreditingProvider' do
          subject { resource[:AccreditingProvider] }

          describe 'Provider_default_value_Mapping' do
            it { should include(Id: 0) }
            it { should include(Courses: nil) }
            it { should include(AccreditedCourses: nil) }
          end
          describe 'Provider_direct_simple_Mappting' do
            it { should include(Name: accrediting_provider.provider_name) }
            it { should include(ProviderCode: accrediting_provider.provider_code) }
          end
        end
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
