require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  describe 'json output' do
    let(:resource) { serialize(course, serializer_class: described_class) }

    subject { resource }

    context 'an existing course' do
      let(:with_send_subject) { true }
      let(:subject_names) { %w[Primary] }
      let(:course_subjects) do
        subjects = subject_names.map do |subject_name|
          build(:subject, subject_name: subject_name)
        end

        subjects << build(:send_subject) if with_send_subject
        { subjects: subjects }
      end

      let(:course_factory_args) do
        {
          provider: provider,
          accrediting_provider: accrediting_provider,
          name: 'Primary (Special Educational Needs)',
          course_code: '2KXB',
          start_date: '2019-08-01T00:00:00',
          subject_count: 0,
          **course_subjects
        }
      end

      let(:course) do
        create :course, **course_factory_args
      end

      let(:provider) do
        build :provider,
              provider_name: 'Gateway Alliance (Midlands)',
              provider_code: '23E'
      end
      let(:accrediting_provider) do
        build :provider,
              provider_name: 'The University of Warwick',
              provider_code: 'W20'
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

      describe 'Salary_nested_default_value_Mapping' do
        subject { resource[:Salary] }

        it { should include(Minimum: nil) }
        it { should include(Maximum: nil) }
      end

      describe 'Subjects_related_Mapping' do
        it { should include(IsSen: course.is_send?) }

        describe 'CourseSubjects' do
          subject { resource[:CourseSubjects] }
          let(:expected_course_subjects) do
            subject_names.map do |subject_name|
              { # CourseSubject_default_value_mapping
                CourseId: 0,
                Course: nil,
                SubjectId: 0,
                # CourseSubject_complex
                Subject:
                  {
                    # Subject_default_value_Mapping
                    Id: 0,
                    SubjectArea: nil,
                    FundingId: nil,
                    Funding: nil,
                    IsSubjectKnowledgeEnhancementAvailable: false,
                    CourseSubjects: nil,

                    # Subject_direct_Mapping
                    Name: subject_name,
                  }
                }
            end
          end
          it { should match_array expected_course_subjects }
        end
      end

      # should work fine once hardcoded/db ones are flushed out
      xit { should eq expected_json }
    end
  end
end
