require 'rails_helper'

describe SearchAndCompare::CourseSerializer do
  let(:course) { create :course }

  describe 'json output' do
    subject { serialize(course, serializer_class: described_class) }

    context 'an existing course' do
      let(:accrediting_provider) do
        create :provider,
               provider_code: 'M80',
               provider_name: 'Middlesex University'
      end
      let(:provider) do
        create :provider,
               provider_code: '189',
               provider_name: 'Bowes Primary School'
      end
      let(:course) do
        create :course,
               provider: provider,
               course_code: '22FV',
               accrediting_provider: accrediting_provider
      end
      let(:expected_json) do
        file = File.read("#{Dir.pwd}/spec/serializers/search_and_compare/course_serializer_test_data.json")
        JSON.parse(file)
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

      it { should include(Name: course.name) }
      it { should include(ProgrammeCode: course.course_code) }

      xit { should eq expected_json }
    end
  end
end
