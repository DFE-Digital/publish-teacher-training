require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  let(:course) { create :course }

  describe 'json output' do
    let(:resource) { serialize(course, serializer_class: described_class) }

    subject { resource }
    context 'an existing course' do
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

      let(:mappings_yaml) do
        HashWithIndifferentAccess.new(YAML.load_file("#{Dir.pwd}/spec/serializers/search_and_compare/mappings.yaml"))
      end

      let(:course_factory_args) do
        {
          provider: provider,
          accrediting_provider: accrediting_provider,
          name: expected_json[:Name],
          course_code: expected_json[:ProgrammeCode],
          start_date: expected_json[:StartDate],
        }
          # # site_statuses.findable.with_vacancies
          # has_vacancies?: expected_json[:HasVacancies],
          # # should add sen subject
          # is_send?: expected_json[:IsSen],
      end

      let(:course) do
        create :course, **course_factory_args
      end
      let(:expected_json) do
        file = File.read("#{Dir.pwd}/spec/serializers/search_and_compare/course_serializer_test_data.json")
        HashWithIndifferentAccess.new(JSON.parse(file))
      end

      let(:json_stringifyed) do
        JSON.pretty_generate(expected_json)
      end

      let(:annotated_yaml) do
        yaml = YAML.load_file("#{Dir.pwd}/spec/serializers/search_and_compare/test_data.yaml")
        JSON.pretty_generate(yaml)
      end

      it 'yaml and json should be the same' do
        # Sanity check,
        # annotated_yaml, is used for annotation in order to do the 'let' and flush out the serializer
        # json_stringifyed, is just expected_json
        # expected_json, is the the thing to actually test
        expect(json_stringifyed).to eq(annotated_yaml)
      end

      it 'x' do
        # pp resource
      #   pp '{'
      #   blah = mappings_yaml[:Course_direct_simple_Mapping].select do |k, _v|
      #     next if k.starts_with? '_'

      #     # x = v.present? ? v.to_s : 'nil'
      #     # pp "attribute(:#{k})".ljust(50) + "{ object.#{x} }"
      #     ##pp "it { should include(#{k}: course.#{x}) }"
      #     #pp v
      #     #pp "#{v}: expected_json[#{k}],"
      #     pp "it { should include(#{k}: #{expected_json[k]} },"
      #   end
      #   pp '}'
      end

      # actual vs db
      describe 'Course_direct_Mapping' do
        it { should include(Name: course.name) }
        it { should include(ProgrammeCode: course.course_code) }
        it { should include(StartDate: course.start_date) }
        it { should include(HasVacancies: course.has_vacancies?) }
        it { should include(IsSen: course.is_send?) }
      end

      # actual vs hardcoded
      describe 'json Actual values' do
        it { should include(Name: 'Primary') }
        it { should include(ProgrammeCode: '22FV') }
        it { should include(StartDate: '2019-09-01T00:00:00') }
        # it { should include(HasVacancies: true },
        # it { should include(IsSen: false },
      end

      # actual vs hardcoded
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

      # actual vs db

      describe 'Course_nested_object_Mapping' do
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

        describe 'IsSalaried' do
          it { should include(IsSalaried: !course.is_fee_based?) }
        end

        describe 'Route' do
          subject { resource[:Route] }
          # dont think that the right thing
          it { should include(Name: course.program_type) }
          it { should include(IsSalaried: !course.is_fee_based?) }
        end

        describe 'CourseSubjects' do
          subject { resource[:CourseSubjects] }

          it { pp course.subjects }
          it { pp course.dfe_subjects }
          its(:size) { should eq course.dfe_subjects.size }
        end
      end

      # should work fine once hardcoded/db ones are flushed out
      xit { should eq expected_json }
    end
  end
end
