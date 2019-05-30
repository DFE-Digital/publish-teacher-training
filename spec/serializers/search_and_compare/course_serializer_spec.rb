require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  describe 'json output' do
    let(:resource) { serialize(course, serializer_class: described_class) }

    subject { resource }

    context 'an existing course' do
      let(:with_send_subject) { true }
      let(:subject_names) { %w[Primary] }
      let(:subjects) do
        subjects = subject_names.map do |subject_name|
          build(:subject, subject_name: subject_name)
        end

        subjects << build(:send_subject) if with_send_subject

        subjects
      end

      let(:course) do
        create(:course,
               provider: provider,
               accrediting_provider: accrediting_provider,
               name: 'Primary (Special Educational Needs)',
               course_code: '2KXB',
               start_date: '2019-08-01T00:00:00',
               subject_count: 0,
               program_type: :school_direct_salaried_training_programme,
               qualification: :pgce_with_qts,
               study_mode:  :full_time,
               site_statuses: [site_status1, site_status2],
               enrichments: [published_enrichment],
               subjects: subjects).tap do |c|

          # These sites, taken from real prod data, aren't actually valid in
          # that they're missing the following bits of data.
          c.site_statuses.each do |site_status|
            site_status.site.address2 = ''
            site_status.site.address3 = ''
            site_status.site.address4 = ''
            site_status.site.postcode = ''
            site_status.site.save validate: false
            site_status.save validate: false
          end
        end
      end

      let(:published_enrichment) do
        build :course_enrichment, :published,
              course_length: "OneYear",
              created_at: 5.days.ago,

              # describe tattributes in the o DescriptionSections_Mapping section
              about_course: 'about_course',
              interview_process: 'interview_process',
              fee_details: 'fee_details',
              salary_details: 'salary_details',
              qualifications: 'qualifications',
              personal_qualities: 'personal_qualities',
              other_requirements: 'other_requirements',
              financial_support: 'financial_support',
              how_school_placements_work: 'how_school_placements_work'
      end

      let(:accrediting_provider_enrichment) do
        {
          'UcasProviderCode' => accrediting_provider.provider_code,
          'Description' => 'accrediting_provider_enrichment_description'
        }
      end

      let(:site1) do
        build :site,
              location_name: 'Stratford-Upon-Avon & South Warwickshire',
              code: 'S',
              address1: 'CV37'
      end

      let(:site_status1) do
        build :site_status, :findable, :full_time_vacancies,
              site: site1,
              applications_accepted_from: '2018-10-09T00:00:00'
      end

      let(:site2) do
        build :site,
              location_name: 'Nuneaton & Bedworth',
              code: 'N',
              address1: 'CV10'
      end

      let(:site_status2) do
        build :site_status, :findable, :full_time_vacancies,
              site: site2
      end

      let(:provider_enrichment) do
        build :provider_enrichment, :published,
              last_published_at: 1.day.ago,
              address1: "c/o Claverdon Primary School",
              address2: "Breach Lane",
              address3: "Claverdon",
              address4: "Warwick",
              postcode: "CV35 8QA",
              telephone: "02476 347697",
              email: "info@gatewayalliance.co.uk",
              website: "http://www.gatewayalliance.co.uk",

              # DescriptionSections_Mapping section
              train_with_us: 'train_with_us',
              train_with_disability: 'train_with_disability',
              accrediting_provider_enrichments: [accrediting_provider_enrichment]
      end

      let(:provider) do
        create :provider,
               provider_name: 'Gateway Alliance (Midlands)',
               provider_code: '23E',
               enrichments: [provider_enrichment]
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

      # This test is the overall test of 'rails' vs 'csharp' generated json
      context 'original json' do
        it { should eq expected_json }
      end

      # All the tests belows are the more intimate for the expected 32 fields and its related nested fields
      # Tests consistence of
      #   database models mapping to json
      #   default values
      describe 'attributes in the Provider_serializer_Mapping section' do
        describe 'Provider' do
          subject { resource[:Provider] }
          let(:expected_provider) do
            ActiveModelSerializers::SerializableResource.new(
              provider,
              serializer: SearchAndCompare::ProviderSerializer,
              adapter: :attributes
            ).serializable_hash.with_indifferent_access
          end

          it { should eq expected_provider }
        end

        describe 'AccreditingProvider' do
          subject { resource[:AccreditingProvider] }
          let(:expected_accrediting_provider) do
            ActiveModelSerializers::SerializableResource.new(
              accrediting_provider,
              serializer: SearchAndCompare::ProviderSerializer,
              adapter: :attributes
            ).serializable_hash.with_indifferent_access
          end

          it { should eq expected_accrediting_provider }
        end
      end

      describe 'attributes in the Course_default_value_Mapping section' do
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

      describe 'attributes in the Course_direct_Mapping section' do
        it { should include(Name: course.name) }
        it { should include(ProgrammeCode: course.course_code) }
        it { should include(StartDate: course.start_date) }
      end

      describe 'attributes in the Salary_nested_default_value_Mapping section' do
        subject { resource[:Salary] }

        it { should include(Minimum: nil) }
        it { should include(Maximum: nil) }
      end

      describe 'attributes in the Subjects_related_Mapping section' do
        it { should include(IsSen: course.is_send?) }

        describe 'CourseSubjects' do
          subject { resource[:CourseSubjects] }
          let(:expected_course_subjects) do
            subject_names.map do |subject_name|
              {
                CourseId: 0,
                Course: nil,
                SubjectId: 0,
                Subject:
                  {
                    Id: 0,
                    SubjectArea: nil,
                    FundingId: nil,
                    Funding: nil,
                    IsSubjectKnowledgeEnhancementAvailable: false,
                    CourseSubjects: nil,
                    Name: subject_name,
                  }
                }
            end
          end

          it { should match_array expected_course_subjects }
        end
      end

      describe 'attributes in the Campuses_related_Mapping section' do
        it { should include(ApplicationsAcceptedFrom: '2018-10-09T00:00:00') }
        it { should include(HasVacancies: course.has_vacancies?) }

        describe 'Campuses' do
          subject { resource[:Campuses] }
          let(:expected_campuses) {
            course.site_statuses.findable.map do |site_status|
              address = [
                site_status.site.address1,
                site_status.site.address2,
                site_status.site.address3,
                site_status.site.address4,
                site_status.site.postcode
              ].reject(&:blank?).join('\n')

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
        end
      end

      describe 'attributes in the Course_variant_Mapping section' do
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

          describe 'attributes in the Route_default_value_Mapping section' do
            it { should include(Id: 0) }
            it { should include(Courses: nil) }
          end

          describe 'attributes in the Route_Complex_value_Mapping section'do
            # related to the course's program_type
            it { should include(Name: 'School Direct (salaried) training programme') }
            # related to the course's program_type
            it { should include(IsSalaried: !course.is_fee_based?) }
          end
        end
      end

      describe 'attributes in the Course_direct_enrichment_Mapping section' do
        it { should include(Duration: '1 year') }
        describe 'Fees' do
          subject { resource[:Fees] }
          let(:course_enrichment) { course.enrichments.published.latest_first.first }

          it { should include(Uk: course.is_fee_based? ? course_enrichment.fee_uk_eu : 0) }
          it { should include(Eu: course.is_fee_based? ? course_enrichment.fee_uk_eu : 0) }
          it { should include(International: course.is_fee_based? ? course_enrichment.fee_international : 0) }
        end
      end

      describe 'attributes in the Provider_contact_info_Mapping section' do
        let(:expected_address) do
          "c/o Claverdon Primary School\nBreach Lane\nClaverdon\nWarwick\nCV35 8QA"
        end

        describe 'ContactDetails' do
          subject { resource[:ContactDetails] }

          it { should include(Id: 0) }
          it { should include(Phone: "02476 347697") }
          it { should include(Fax: nil) }
          it { should include(Email: "info@gatewayalliance.co.uk") }
          it { should include(Website: "http://www.gatewayalliance.co.uk") }
          it { should include(Course: nil) }
          it { should include(Address: expected_address) }
        end

        describe 'ProviderLocation' do
          subject { resource[:ProviderLocation] }

          it { should include(Id: 0) }
          it { should include(FormattedAddress: nil) }
          it { should include(GeoAddress: nil) }
          it { should include(Latitude: nil) }
          it { should include(Longitude: nil) }
          it { should include(LastGeocodedUtc: '0001-01-01T00:00:00') }
          it { should include(Address: expected_address) }
        end
      end

      describe 'attributes in the DescriptionSections_Mapping section' do
        subject { resource[:DescriptionSections] }

        shared_examples 'mapped the description section' do |name, text|
          describe "#{name} should be mapped to description section" do
            expected_description_section = {
              Id: 0,
              Ordinal: 0,
              CourseId: 0,
              Course: nil,
              Name: name,
              Text: text,
            }

            it { should include expected_description_section }
          end
        end

        include_examples 'mapped the description section', 'about this training programme', 'about_course'
        include_examples 'mapped the description section', 'interview process', 'interview_process'
        include_examples 'mapped the description section', 'about fees', 'fee_details'
        include_examples 'mapped the description section', 'about salary', 'salary_details'
        include_examples 'mapped the description section', 'entry requirements', 'qualifications'
        include_examples 'mapped the description section', 'entry requirements personal qualities', 'personal_qualities'
        include_examples 'mapped the description section', 'entry requirements other', 'other_requirements'
        include_examples 'mapped the description section', 'financial support', 'financial_support'
        include_examples 'mapped the description section', 'about school placements', 'how_school_placements_work'
        include_examples 'mapped the description section', 'about this training provider', 'train_with_us'
        include_examples 'mapped the description section', 'about this training provider accrediting', 'accrediting_provider_enrichment_description'
        include_examples 'mapped the description section', 'training with disabilities', 'train_with_disability'
      end
    end
  end
end
