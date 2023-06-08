# frozen_string_literal: true

require 'rails_helper'

module Find
  describe ResultsView do
    let(:query_parameters) { ActionController::Parameters.new(parameter_hash) }

    let(:default_output_parameters) do
      {
        'qualification' => ['qts', 'pgce_with_qts', 'pgce pgde'],
        'study_type' => %w[full_time part_time],
        'has_vacancies' => true,
        'send_courses' => false
      }
    end

    describe '#query_parameters_with_defaults' do
      subject(:results_view) { described_class.new(query_parameters:).query_parameters_with_defaults }

      context 'params are empty' do
        let(:parameter_hash) { {} }

        it { is_expected.to eq(default_output_parameters) }
      end

      context 'query_parameters have qualifications set' do
        let(:parameter_hash) { { 'qualification' => 'pgce pgde' } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context 'query_parameters have fulltime set' do
        let(:parameter_hash) { { 'study_type' => ['full_time'] } }

        it { is_expected.to eq(default_output_parameters.merge('study_type' => ['full_time'])) }
      end

      context 'query_parameters have parttime set' do
        let(:parameter_hash) { { 'study_type' => ['part_time'] } }

        it { is_expected.to eq(default_output_parameters.merge('study_type' => ['part_time'])) }
      end

      context 'query_parameters have has_vacancies set' do
        let(:parameter_hash) { { 'has_vacancies' => 'true' } }

        it { is_expected.to eq(default_output_parameters.merge('has_vacancies' => true)) }
      end

      context 'query_parameters have send_courses set' do
        let(:parameter_hash) { { 'send_courses' => 'false' } }

        it { is_expected.to eq(default_output_parameters.merge('send_courses' => false)) }
      end

      context "query_parameters not lose track of 'l' used by C# radio buttons" do
        let(:parameter_hash) { { 'l' => '2' } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context 'parameters without default present in query_parameters' do
        let(:parameter_hash) { { 'latitude' => '52.3812321', 'longitude' => '-3.9440235' } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end

      context 'rails specific parameters are present' do
        let(:parameter_hash) { { 'utf8' => 'true', 'authenticity_token' => 'booyah' } }

        it 'filters them out' do
          expect(results_view).to eq(default_output_parameters.merge({}))
        end
      end

      context 'query_parameters have subjects set' do
        let(:parameter_hash) { { 'subjects' => '14,41,20' } }

        it { is_expected.to eq(default_output_parameters.merge(parameter_hash)) }
      end
    end

    describe 'filter_path_with_unescaped_commas' do
      let(:default_query_parameters) do
        {
          'qualification' => ['qts', 'pgce_with_qts', 'pgce pgde'],
          'study_type' => %w[full_time part_time],
          'has_vacancies' => 'true',
          'send_courses' => 'false'
        }
      end

      subject(:results_view) { described_class.new(query_parameters: default_query_parameters).filter_params_with_unescaped_commas('/test') }

      it 'appends an unescaped querystring to the passed path' do
        allow(UnescapedQueryStringService).to receive(:call).with(
          base_path: '/test',
          parameters: default_output_parameters
        )
                                                            .and_return('test_result')
        expect(results_view).to eq('test_result')
      end
    end

    describe '#location' do
      subject { described_class.new(query_parameters: parameter_hash).location }

      context 'when loc is passed' do
        let(:parameter_hash) { { 'loc' => 'Hogwarts' } }

        it { is_expected.to eq('Hogwarts') }
      end

      context 'when loc is not passed' do
        let(:parameter_hash) { {} }

        it { is_expected.to eq('Across England') }
      end
    end

    describe '#courses' do
      let(:query_parameters) { {} }

      let(:course_ascending) { 'course_asc' }
      let(:course_descending) { 'course_desc' }
      let(:provider_ascending) { 'provider_asc' }
      let(:provider_descending)  { 'provider_desc' }

      subject { described_class.new(query_parameters:).courses }

      it 'returns a Course ActiveRecord::Relation' do
        expect(subject).to be_a(ActiveRecord::Relation)
      end

      context 'sortby is not set in query_parameters' do
        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)
        end

        it 'delegates to the CourseSearchService with sort set to course_ascending' do
          subject
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(filter: query_parameters, sort: course_ascending)
          )
        end
      end

      context "sortby is set to 'course_asc' in query_parameters" do
        let(:query_parameters) { { sortby: 'course_asc' } }

        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)
        end

        it 'delegates to the CourseSearchService with sort set to course_ascending' do
          subject
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(filter: query_parameters, sort: course_ascending)
          )
        end
      end

      context "sortby is set to 'course_desc' in query_parameters" do
        let(:query_parameters) { { sortby: 'course_desc' } }

        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)
        end

        it 'delegates to the CourseSearchService with sort set to course_descending' do
          subject
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(filter: query_parameters, sort: course_descending)
          )
        end
      end

      context "sortby is set to 'provider_asc' in query_parameters" do
        let(:query_parameters) { { sortby: 'provider_asc' } }

        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)
        end

        it 'delegates to the CourseSearchService with sort set to provider_ascending' do
          subject
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(filter: query_parameters, sort: provider_ascending)
          )
        end
      end

      context "sortby is set to 'provider_desc' in query_parameters" do
        let(:query_parameters) { { sortby: 'provider_desc' } }

        before do
          allow(CourseSearchService).to receive(:call).and_return(Course.all)
        end

        it 'delegates to the CourseSearchService with sort set to provider_descending' do
          subject
          expect(CourseSearchService).to have_received(:call).with(
            hash_including(filter: query_parameters, sort: provider_descending)
          )
        end
      end
    end

    describe '#provider' do
      subject { described_class.new(query_parameters: parameter_hash).provider }

      context 'when query is passed' do
        let(:parameter_hash) { { 'provider.provider_name' => 'Kamino' } }

        it { is_expected.to eq('Kamino') }
      end
    end

    describe '#location_filter?' do
      subject { described_class.new(query_parameters: parameter_hash).location_filter? }

      context 'when l param is set to 1' do
        let(:parameter_hash) { { 'l' => '1' } }

        it { is_expected.to be(true) }
      end

      context 'when l param is not set to 1' do
        let(:parameter_hash) { { 'l' => '2' } }

        it { is_expected.to be(false) }
      end
    end

    describe '#england_filter?' do
      subject { described_class.new(query_parameters: parameter_hash).england_filter? }

      context 'when l param is set to 2' do
        let(:parameter_hash) { { 'l' => '2' } }

        it { is_expected.to be(true) }
      end

      context 'when l param is not set to 2' do
        let(:parameter_hash) { { 'l' => '3' } }

        it { is_expected.to be(false) }
      end
    end

    describe '#provider_filter?' do
      subject { described_class.new(query_parameters: parameter_hash).provider_filter? }

      context 'when l param is set to 3' do
        let(:parameter_hash) { { 'l' => '3' } }

        it { is_expected.to be(true) }
      end

      context 'when l param is not set to 3' do
        let(:parameter_hash) { { 'l' => '2' } }

        it { is_expected.to be(false) }
      end
    end

    describe '#course_count' do
      subject { described_class.new(query_parameters: parameter_hash).course_count }
      let(:parameter_hash) do
        {
          'qualification' => ['qts', 'pgce_with_qts', 'pgce pgde'],
          'fulltime' => 'true',
          'parttime' => 'true',
          'has_vacancies' => 'true',
          'send_courses' => 'false'
        }
      end

      context 'there are more than three results' do
        before do
          Course.destroy_all # for flakey test fail
          allow(CourseSearchService).to receive(:call).and_return(
            instance_double(ActiveRecord::Relation, count: 10)
          )
        end

        it { is_expected.to be(10) }
      end

      context 'there are no results' do
        it { is_expected.to be(0) }
      end
    end

    describe '#subjects' do
      context 'when no parameters are passed' do
        let(:results_view) { described_class.new(query_parameters: {}) }

        it 'returns the subjects in alphabetical order' do
          expect(results_view.subjects.map(&:subject_name)).to eq(
            ['Ancient Greek',
             'Ancient Hebrew',
             'Art and design',
             'Balanced Science',
             'Biology',
             'Business studies',
             'Chemistry',
             'Citizenship',
             'Classics',
             'Communication and media studies',
             'Computing',
             'Dance',
             'Design and technology',
             'Drama',
             'Economics',
             'English',
             'English as a second or other language',
             'French',
             'Further education',
             'Geography',
             'German',
             'Health and social care',
             'History',
             'Humanities',
             'Italian',
             'Japanese',
             'Latin',
             'Mandarin',
             'Mathematics',
             'Modern Languages',
             'Modern languages (other)',
             'Music',
             'Philosophy',
             'Physical education',
             'Physical education with an EBacc subject',
             'Physics',
             'Primary',
             'Primary with English',
             'Primary with geography and history',
             'Primary with mathematics',
             'Primary with modern languages',
             'Primary with physical education',
             'Primary with science',
             'Psychology',
             'Religious education',
             'Russian',
             'Science',
             'Social sciences',
             'Spanish']
          )
        end

        context 'when subject parameters are passed' do
          let(:results_view) do
            described_class.new(query_parameters: {
                                  'subjects' => [
                                    french_subject_code,
                                    russian_subject_code,
                                    primary_subject_code,
                                    spanish_subject_code,
                                    mathematics_subject_code
                                  ]
                                })
          end

          let(:french_subject_code) { '15' }
          let(:primary_subject_code) { '00' }
          let(:spanish_subject_code) { '22' }
          let(:mathematics_subject_code) { 'G1' }
          let(:russian_subject_code) { '21' }

          it 'returns the subjects in alphabetical order' do
            expect(results_view.subjects.map(&:subject_name)).to eq(
              %w[
                French
                Mathematics
                Primary
                Russian
                Spanish
              ]
            )
          end
        end
      end
    end

    describe '#placement_schools_summary' do
      subject(:placement_schools_summary) { results_view.placement_schools_summary(course) }

      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      let(:site1) do
        build(:site, latitude: 51.5079, longitude: 0.0877, address1: '1 Foo Street', postcode: 'BAA0NE')
      end

      let(:site_statuses) do
        [build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1)]
      end

      let(:course) do
        build(
          :course,
          site_statuses:
        )
      end

      context 'site_distance less than 11 miles' do
        let(:parameter_hash) do
          {
            'latitude' => '51.5079',
            'longitude' => '0.0877'
          }
        end

        it { expect(placement_schools_summary).to eq('Placement schools are near you') }
      end

      context 'site_distance less than 21 miles' do
        let(:parameter_hash) do
          {
            'latitude' => '51.6985',
            'longitude' => '0.1367'
          }
        end

        it { expect(placement_schools_summary).to eq('Placement schools might be near you') }
      end

      context 'site_distance more than 21 miles' do
        let(:parameter_hash) do
          {
            'latitude' => '52',
            'longitude' => '0.1367'
          }
        end

        it { expect(placement_schools_summary).to eq('Placement schools might be in commuting distance') }
      end
    end

    describe '#site_distance' do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }

      context 'closest site distance is greater than 1 mile' do
        let(:parameter_hash) { { 'latitude' => '51.4975', 'longitude' => '0.1357' } }

        it 'calculates the distance to the closest site, rounding to one decimal place' do
          site1 = build(:site, latitude: 51.5079, longitude: 0.0877, address1: '1 Foo Street', postcode: 'BAA0NE')
          site2 = build(:site, latitude: 54.9783, longitude: 1.6178, address1: '2 Foo Street', postcode: 'BAA0NE')

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2)
            ]
          )

          expect(results_view.site_distance(course)).to eq(2)
        end
      end

      context 'closest site distance is less than 1 mile' do
        let(:parameter_hash) { { 'latitude' => '51.4975', 'longitude' => '0.1357' } }

        it 'calculates the distance to the closest site, rounding to one decimal place' do
          site1 = build(:site, latitude: 51.4985, longitude: 0.1367, address1: '1 Foo Street', postcode: 'BAA0NE')
          site2 = build(:site, latitude: 54.9783, longitude: 1.6178, address1: '2 Foo Street', postcode: 'BAA0NE')

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2)
            ]
          )

          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end

      context 'closest site distance is less than 0.05 miles' do
        let(:parameter_hash) { { 'latitude' => '51.4975', 'longitude' => '0.1357' } }

        it 'calculates the distance to the closest site, rounding up to prevent 0.0 miles displaying' do
          site1 = build(:site, latitude: 51.4970, longitude: 0.1358, address1: '1 Foo Street', postcode: 'BAA0NE')

          course = build(
            :course,
            site_statuses: [
              build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1)
            ]
          )

          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end
    end

    context 'locations' do
      let(:results_view) { described_class.new(query_parameters: parameter_hash) }
      let(:parameter_hash) { { 'latitude' => '51.4975', 'longitude' => '0.1357' } }
      let(:geocoder) { instance_double(Geokit::LatLng) }

      let(:site1) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1367,
          location_name: 'Main Site',
          address1: '10 Windy Way',
          address2: 'Witham',
          address3: '',
          town: 'Essex',
          address4: 'UK',
          postcode: 'CM8 2SD'
        )
      end
      let(:site2) do
        build(:site, latitude: 54.9783, longitude: 1.6178, location_name: 'no address')
      end
      let(:site3) do
        build(
          :site,
          latitude: nil,
          longitude: nil,
          address1: '10 Windy Way',
          address2: 'Witham',
          address3: '',
          town: 'Essex',
          address4: 'UK',
          postcode: 'CM8 2SD',
          location_name: 'no latitude long'
        )
      end
      let(:site4) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1367,
          address1: '10 Windy Way',
          address2: 'Witham',
          address3: '',
          town: 'Essex',
          address4: 'UK',
          postcode: 'CM8 2SD',
          location_name: 'suspended'
        )
      end

      let(:site5) do
        build(
          :site,
          latitude: 51.4985,
          longitude: 0.1358,
          address1: 'No vacancies road',
          address2: 'Witham',
          address3: '',
          town: 'Essex',
          address4: 'UK',
          postcode: 'CM8 2SD'
        )
      end

      let(:course) do
        build(
          :course,
          site_statuses: [
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site1),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site2),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site3),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, site: site4, status: 'suspended'),
            build(:site_status, :both_full_time_and_part_time_vacancies, :findable, :no_vacancies, site: site5)
          ]
        )
      end

      before do
        course
      end

      describe '#nearest_address' do
        it 'returns the address to the nearest site with vacancies' do
          allow(Geokit::LatLng).to receive(:new).and_return(geocoder)
          allow(geocoder).to receive(:distance_to)
          allow(geocoder).to receive(:distance_to).with('51.4985,0.1367')
          allow(geocoder).to receive(:distance_to).with(',').and_raise(Geokit::Geocoders::GeocodeError)

          expect(results_view.nearest_address(course)).to eq('10 Windy Way, Witham, Essex, UK, CM8 2SD')
        end
      end

      describe '#nearest_location_name' do
        it 'returns the location name to the nearest site' do
          allow(Geokit::LatLng).to receive(:new).and_return(geocoder)
          allow(geocoder).to receive(:distance_to)
          allow(geocoder).to receive(:distance_to).with('51.4985,0.1367')
          allow(geocoder).to receive(:distance_to).with(',').and_raise(Geokit::Geocoders::GeocodeError)

          expect(results_view.nearest_location_name(course)).to eq('Main Site')
        end
      end

      describe '#sites_count' do
        it 'returns the running or new sites with geo data count' do
          expect(results_view.sites_count(course)).to eq(3)
        end
      end

      describe '#site_distance' do
        it 'returns the running or new sites with vacancies count' do
          expect(results_view.site_distance(course)).to eq(0.1)
        end
      end
    end

    describe '#sort_options' do
      context 'all other queries' do
        subject(:results_view) { described_class.new(query_parameters: {}).sort_options }

        it {
          expect(results_view).to eq(
            [
              ['Course name (A-Z)', 'course_asc', { 'data-qa': 'sort-form__options__ascending_course' }],
              ['Course name (Z-A)', 'course_desc', { 'data-qa': 'sort-form__options__descending_course' }],
              ['Training provider (A-Z)', 'provider_asc', { 'data-qa': 'sort-form__options__ascending_provider' }],
              ['Training provider (Z-A)', 'provider_desc', { 'data-qa': 'sort-form__options__descending_provider' }]
            ]
          )
        }
      end
    end

    describe '#no_results_found?' do
      subject { described_class.new(query_parameters: {}).no_results_found? }
      let(:site) { build(:site) }
      let(:site_status) { create(:site_status, :findable, site:) }
      let(:site_status1) { create(:site_status, :findable, site:) }
      let(:site_status2) { create(:site_status, :findable, site:) }
      let(:site_status3) { create(:site_status, :findable, site:) }
      let(:site_status4) { create(:site_status, :findable, site:) }

      context 'there are more than three results' do
        before do
          Course.destroy_all # for flakey test fail
          create(:course, site_statuses: [site_status])
          create(:course, site_statuses: [site_status1])
          create(:course, site_statuses: [site_status2])
          create(:course, site_statuses: [site_status3])
        end

        it { is_expected.to be(false) }
      end

      context 'there are no results' do
        it { is_expected.to be(true) }
      end
    end

    describe '#number_of_courses_string' do
      subject { described_class.new(query_parameters: {}).number_of_courses_string }
      let(:site) { build(:site) }
      let(:site_status) { create(:site_status, :findable, site:) }
      let(:site_status1) { create(:site_status, :findable, site:) }

      context 'there are two results' do
        before do
          Course.destroy_all # for flakey test fail
          create(:course, site_statuses: [site_status])
          create(:course, site_statuses: [site_status1])
        end

        it { is_expected.to eq('2 courses') }
      end

      context 'there is one result' do
        before do
          create(:course, site_statuses: [site_status])
        end

        it { is_expected.to eq('1 course') }
      end

      context 'there are no results' do
        it { is_expected.to eq('No courses') }
      end
    end

    describe '#devolved_nation' do
      context 'where country is devolved nation' do
        let(:results_view) { described_class.new(query_parameters: { 'c' => 'Wales' }) }

        it 'returns true' do
          expect(results_view.devolved_nation?).to be true
        end
      end

      context 'where country is not a devolved nation' do
        let(:results_view) { described_class.new(query_parameters: { 'c' => 'Italy' }) }

        it 'returns false' do
          expect(results_view.devolved_nation?).to be false
        end
      end

      context 'where country is England' do
        let(:results_view) { described_class.new(query_parameters: { 'c' => 'England' }) }

        it 'returns false' do
          expect(results_view.devolved_nation?).to be false
        end
      end

      context 'where country is nil' do
        let(:results_view) { described_class.new(query_parameters: { 'c' => 'nil' }) }

        it 'returns false' do
          expect(results_view.devolved_nation?).to be false
        end
      end
    end

    describe '#filter_params_for' do
      context 'when the user has searched for a location that is within a devolved nation' do
        let(:query_parameters) do
          {
            'c' => 'Wales',
            'latitude' => '1.23456',
            'long' => '0.54321',
            'loc' => 'Cardiff',
            'lq' => 'Cardiff',
            'l' => '1'
          }
        end

        subject(:results_view) { described_class.new(query_parameters:) }

        it 'returns default params without the location params' do
          expect(results_view.filter_params_for('/')).to eq '/?has_vacancies=true&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time'
        end
      end

      context 'when the user has searched for a location that is within England' do
        let(:query_parameters) do
          {
            'c' => 'England',
            'latitude' => '1.23456',
            'long' => '0.54321',
            'loc' => 'Brixton',
            'lq' => 'Brixton',
            'l' => '1'
          }
        end

        subject(:results_view) { described_class.new(query_parameters:) }

        it 'returns default params without the location params' do
          expect(results_view.filter_params_for('/')).to eq '/?c=England&has_vacancies=true&l=1&latitude=1.23456&loc=Brixton&long=0.54321&lq=Brixton&qualification%5B%5D=qts&qualification%5B%5D=pgce_with_qts&qualification%5B%5D=pgce+pgde&send_courses=false&study_type%5B%5D=full_time&study_type%5B%5D=part_time'
        end
      end
    end
  end
end
