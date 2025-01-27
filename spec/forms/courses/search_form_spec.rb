# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Courses::SearchForm do
  describe '#search_params' do
    context 'when can_sponsor_visa is true' do
      let(:form) { described_class.new(can_sponsor_visa: 'true') }

      it 'returns the correct search params with can_sponsor_visa set to true' do
        expect(form.search_params).to eq({ can_sponsor_visa: true })
      end
    end

    context 'when can_sponsor_visa is false' do
      let(:form) { described_class.new(can_sponsor_visa: 'false') }

      it 'returns the correct search params with can_sponsor_visa set to false' do
        expect(form.search_params).to eq({ can_sponsor_visa: false })
      end
    end

    context 'when send_courses is true' do
      let(:form) { described_class.new(send_courses: 'true') }

      it 'returns the correct search params with send_courses set to true' do
        expect(form.search_params).to eq({ send_courses: true })
      end
    end

    context 'when send_courses is false' do
      let(:form) { described_class.new(send_courses: 'false') }

      it 'returns the correct search params with send_courses set to false' do
        expect(form.search_params).to eq({ send_courses: false })
      end
    end

    context 'when applications_open is true' do
      let(:form) { described_class.new(applications_open: 'true') }

      it 'returns the correct search params with applications_open set to true' do
        expect(form.search_params).to eq({ applications_open: true })
      end
    end

    context 'when applications_open is false' do
      let(:form) { described_class.new(applications_open: 'false') }

      it 'returns the correct search params with applications_open set to false' do
        expect(form.search_params).to eq({ applications_open: false })
      end
    end

    context 'when study_types are provided' do
      let(:form) { described_class.new(study_types: %w[full_time part_time]) }

      it 'returns the correct search params with study_types as an array' do
        expect(form.search_params).to eq({ study_types: %w[full_time part_time] })
      end
    end

    context 'when further education is provided' do
      context 'when new level params' do
        let(:form) { described_class.new(level: 'further_education') }

        it 'returns level search params' do
          expect(form.search_params).to eq({ level: 'further_education' })
        end
      end

      context 'when old age group params is used' do
        let(:form) { described_class.new(age_group: 'further_education') }

        it 'returns level search params' do
          expect(form.search_params).to eq({ level: 'further_education' })
        end
      end

      context 'when old qualification params is used as string' do
        let(:form) { described_class.new(qualification: ['pgce pgde']) }

        it 'returns level search params' do
          expect(form.search_params).to eq({ level: 'further_education' })
        end
      end
    end

    context 'when minimum degree grade is provided' do
      shared_examples 'minimum degree required in search params' do |mapping|
        let(:form) { described_class.new(mapping[:from]) }

        it "maps #{mapping[:from]} to #{mapping[:to]}" do
          expect(form.search_params).to eq(mapping[:to])
        end

        it "returns the expected #{mapping[:to].keys.first} value" do
          expect(form.minimum_degree_required).to eq(mapping[:to].values.first)
        end
      end

      context 'when new params' do
        include_examples 'minimum degree required in search params',
                         from: { minimum_degree_required: 'two_one' },
                         to: { minimum_degree_required: 'two_one' }
      end

      context 'when old 2:1 params is used' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'show_all_courses' },
                         to: { minimum_degree_required: 'two_one' }
      end

      context 'when old 2:2 params is used' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'two_two' },
                         to: { minimum_degree_required: 'two_two' }
      end

      context 'when old "Third class" params is used' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'third_class' },
                         to: { minimum_degree_required: 'third_class' }
      end

      context 'when old "Pass" params is used' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'not_required' },
                         to: { minimum_degree_required: 'pass' }
      end

      context 'when old undergraduate params is used' do
        include_examples 'minimum degree required in search params',
                         from: { university_degree_status: false },
                         to: { minimum_degree_required: 'no_degree_required' }
      end

      context 'when old undergraduate params is used always takes precedence over degree required old param' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'show_all_courses', university_degree_status: false },
                         to: { minimum_degree_required: 'no_degree_required' }
      end

      context 'when param value does not exist' do
        include_examples 'minimum degree required in search params',
                         from: { degree_required: 'does_not_exist' },
                         to: {}
      end

      context 'when show postgraduate params is used' do
        include_examples 'minimum degree required in search params',
                         from: { university_degree_status: true },
                         to: {}
      end
    end

    context 'when funding is provided' do
      let(:form) { described_class.new(funding: %w[fee salary]) }

      it 'returns the correct search params with funding as an array' do
        expect(form.search_params).to eq({ funding: %w[fee salary] })
      end
    end

    context 'when searching by provider' do
      context 'when using the new parameter' do
        let(:form) { described_class.new(provider_name: 'NIoT') }

        it 'returns the correct search params with provider name' do
          expect(form.search_params).to eq({ provider_name: 'NIoT' })
        end
      end

      context 'when using the old parameter' do
        let(:form) { described_class.new('provider.provider_name': 'NIoT') }

        it 'returns the correct search params with provider name' do
          expect(form.search_params).to eq({ provider_name: 'NIoT' })
        end
      end
    end

    context 'when location is provided' do
      let(:form) { described_class.new(location: 'London NW9, UK', latitude: 51.53328, longitude: -0.1734435, radius: 10) }

      it 'returns the correct search params with location details' do
        expect(form.search_params).to eq(location: 'London NW9, UK', latitude: 51.53328, longitude: -0.1734435, radius: 10)
      end
    end

    context 'when no attributes are set' do
      let(:form) { described_class.new }

      it 'returns empty search params' do
        expect(form.search_params).to eq({})
      end
    end

    context 'when multiple attributes are set' do
      let(:form) { described_class.new(can_sponsor_visa: 'true', send_courses: 'true', study_types: ['full_time']) }

      it 'returns the correct search params with all attributes' do
        expect(form.search_params).to eq({ can_sponsor_visa: true, send_courses: true, study_types: ['full_time'] })
      end
    end

    context 'when attributes contain nil values' do
      let(:form) { described_class.new(can_sponsor_visa: nil, send_courses: 'false') }

      it 'returns search params without nil values' do
        expect(form.search_params).to eq({ send_courses: false })
      end
    end
  end
end
