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

      let(:course_variant) do
        { program_type: :school_direct_salaried_training_programme,
          qualification: :pgce_with_qts,
          study_mode:  :full_time, }
      end

      let(:site_statuses_and_sites) do
        site_statuses_and_sites = [
          {
            site_status_traits: %i[findable full_time_vacancies],
            site_status_attrs: { applications_accepted_from: '2018-10-09T00:00:00' },
            site_attrs: {
              location_name: 'Stratford-Upon-Avon & South Warwickshire',
              code: 'S',
              address1: 'CV37',
              address2: '',
              address3: '',
              address4: '',
              postcode: '',

            },
            site_save_validate: false
          },
          {
            site_status_traits: %i[findable full_time_vacancies],
            site_status_attrs: { applications_accepted_from: '' },
            site_attrs: {
              location_name: 'Nuneaton & Bedworth',
              code: 'N',
              address1: 'CV10',
              address2: '',
              address3: '',
              address4: '',
              postcode: ''
            },
            site_save_validate: false
          },
        ]
        { site_statuses_and_sites: site_statuses_and_sites }
      end

      let(:course_factory_args) do
        {
          provider: provider,
          accrediting_provider: accrediting_provider,
          name: 'Primary (Special Educational Needs)',
          course_code: '2KXB',
          start_date: '2019-08-01T00:00:00',
          subject_count: 0,
          **course_subjects,
          **course_variant,
          **site_statuses_and_sites,
        }
      end

      let(:course) {
        create :course, **course_factory_args
      }

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

          context 'json' do
            subject { expected_json[:CourseSubjects] }
            it { should match_array expected_course_subjects }
          end
        end
      end

      describe 'Campuses_related_Mapping' do
        it { should include(ApplicationsAcceptedFrom: '2018-10-09T00:00:00') }
        it { should include(HasVacancies: course.has_vacancies?) }

        describe 'Campuses' do
          subject { resource[:Campuses] }
          let(:expected_campuses) {
            course.site_statuses.findable.map do |site_status|
              address = [site_status.site.address1, site_status.site.address2, site_status.site.address3, site_status.site.address4, site_status.site.postcode].reject(&:blank?).join('/n')
              {
                Id: 0,
                LocationId: nil,
                Course: nil,
                VacStatus: site_status.vac_status_before_type_cast,
                Name: site_status.site.location_name,
                CampusCode: site_status.site.code,
                Location: { Id: 0,
                  FormattedAddress: nil,
                  GeoAddress: nil,
                  Latitude: nil,
                  Longitude: nil,
                  LastGeocodedUtc: '0001-01-01T00:00:00',
                   Address: address }
              }
            end
          }
          it { should match_array expected_campuses }
          context 'json' do
            subject { expected_json[:Campuses] }
            it { should match_array expected_campuses }
          end
        end
      end

      describe 'Course_variant_Mapping' do
        # related to the course's qualification + program_type + study_mode
        it { should include(Mod: 'PGCE with QTS full time with salary') }

        # related to the course's program_type
        it { should include(IsSalaried: !course.is_fee_based?) }

        # related to the course's qualification
        it { should include(IncludesPgce: 1) }

        # related to the course's study_mode
        it { should include(FullTime: 1) }
        it { should include(PartTime: 3) }

        describe 'Route' do
          subject { resource[:Route] }

          describe 'Route_default_value_Mapping' do
            it { should include(Id: 0) }
            it { should include(Courses: nil) }
          end
          describe 'Route_Complex_value_Mapping'do
            # related to the course's program_type
            it { should include(Name: 'School Direct (salaried) training programme') }
            # related to the course's program_type
            it { should include(IsSalaried: !course.is_fee_based?) }
          end

          describe 'json' do
            it { should eq expected_json[:Route] }
          end
        end
      end

      # should work fine once hardcoded/db ones are flushed out
      xit { should eq expected_json }
    end
  end
end
