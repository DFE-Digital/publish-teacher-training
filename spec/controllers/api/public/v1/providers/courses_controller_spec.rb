# frozen_string_literal: true

require 'rails_helper'

RSpec.describe API::Public::V1::Providers::CoursesController do
  let(:provider) { create(:provider) }
  let(:recruitment_cycle) { provider.recruitment_cycle }

  describe '#index' do
    context 'when there are no courses' do
      before do
        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code
        }
      end

      it 'returns empty array of data' do
        expect(json_response['data']).to eql([])
      end
    end

    context 'when there are courses' do
      before do
        create_list(:course, 3, provider:)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code
        }
      end

      it 'returns correct number of courses' do
        expect(json_response['data'].size).to be(3)
      end

      context 'course count' do
        it 'returns the course count in a meta object' do
          meta = json_response['meta']

          expect(meta['count']).to be(3)
        end
      end
    end

    context 'returns all course types' do
      it 'returns undergraduate and postgraduate' do
        undergraduate_course = create(:course, :published_teacher_degree_apprenticeship, provider:)
        postgraduate_course = create(:course, :published_postgraduate, provider:)
        provider.courses << [undergraduate_course, postgraduate_course]

        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code
        }

        actual = json_response['data'].map do |data|
          {
            id: data['id'],
            qualifications: data['attributes']['qualifications'],
            program_type: data['attributes']['program_type']
          }
        end

        expect(actual).to include({
                                    id: undergraduate_course.id.to_s,
                                    qualifications: %w[qts undergraduate_degree],
                                    program_type: 'teacher_degree_apprenticeship'
                                  })

        expect(actual).to include({
                                    id: postgraduate_course.id.to_s,
                                    qualifications: %w[qts pgce],
                                    program_type: 'pg_teaching_apprenticeship'
                                  })
      end
    end

    context 'avoids duplication' do
      it 'does not return duplicates across multiple pages by ordering the courses' do
        provider.courses << build_list(:course, 30, provider:)
        ids = []

        (1..10).each do |page|
          get :index, params: {
            recruitment_cycle_year: recruitment_cycle.year,
            provider_code: provider.provider_code,
            page:,
            per_page: 3
          }

          ids += response.parsed_body['data'].pluck('id')
        end

        expect(ids.size).to eq(ids.uniq.size)
        expect(ids).to eq(ids.sort)
      end
    end

    context 'with pagination' do
      let!(:courses) { create_list(:course, 3, provider:) }
      let(:pagination) do
        {
          page:,
          per_page: 3
        }
      end

      before do
        provider.courses << build_list(:course, 5, provider:)

        get :index, params: {
          recruitment_cycle_year: recruitment_cycle.year,
          provider_code: provider.provider_code,
          **pagination
        }
      end

      context 'when requested page is valid' do
        let(:first_page) { 1 }
        let(:last_page) { 3 }

        let(:url_prefix) do
          "http://test.host/api/public/v1/recruitment_cycles/#{recruitment_cycle.year}/providers/#{provider.provider_code}/courses?page="
        end

        context 'page 1' do
          let(:page) { first_page }

          it 'returns links' do
            links = json_response['links']

            expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=3"
            expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=3"
            expect(links['prev']).to be_nil
            expect(links['next']).to eq "#{url_prefix}#{page + 1}&per_page=3"
          end
        end

        context 'page 2' do
          let(:page) { 2 }

          it 'returns links' do
            links = json_response['links']

            expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=3"
            expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=3"
            expect(links['prev']).to eq "#{url_prefix}#{page - 1}&per_page=3"
            expect(links['next']).to eq "#{url_prefix}#{page + 1}&per_page=3"
          end
        end

        context 'page 3' do
          let(:page) { last_page }

          it 'returns links' do
            links = json_response['links']

            expect(links['first']).to eq "#{url_prefix}#{first_page}&per_page=3"
            expect(links['last']).to eq "#{url_prefix}#{last_page}&per_page=3"
            expect(links['prev']).to eq "#{url_prefix}#{page - 1}&per_page=3"
            expect(links['next']).to be_nil
          end
        end
      end

      describe 'overflow' do
        context 'page 4' do
          let(:page) { 4 }

          it 'returns no links' do
            links = json_response['links']

            expect(links).to be_nil
          end

          it 'returns a bad request response' do
            expect(response).to have_http_status(:bad_request)
          end

          it 'returns a friendly error message' do
            expect(json_response['errors'][0]['detail']).to eql(I18n.t('pagy.overflow'))
          end
        end
      end
    end

    describe 'filtering' do
      it 'calls CoursesController with passed filter' do
        expected_filter = ActionController::Parameters.new(funding_type: 'salary')
        expect(CourseSearchService).to receive(:call).with(hash_including(filter: expected_filter)).and_return(Course.all)

        get :index, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          filter: {
            funding_type: 'salary'
          }
        }
      end
    end

    describe 'include' do
      let!(:course) { create(:course, :with_accrediting_provider, provider:) }

      context 'when includes specified' do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            include: 'provider,accredited_body'
          }
        end

        it 'returns the provider and accredited provider connected to the course' do
          expect(json_response['data'][0]['relationships'].keys).to include('provider')
          expect(json_response['data'][0]['relationships'].keys).to include('accredited_body')
          # expect(json_response['included'][0]['id']).to eql(course.accrediting_provider.id.to_s)
          expect(json_response['included'][0]['type']).to eql('providers')
          expect(json_response['included'][1]['id']).to eql(provider.id.to_s)
          expect(json_response['included'][1]['type']).to eql('providers')
        end
      end

      context 'when includes are not part of the serailizer' do
        before do
          get :index, params: {
            recruitment_cycle_year: provider.recruitment_cycle.year,
            provider_code: provider.provider_code,
            include: 'subjects'
          }
        end

        it "doesn't include subjects" do
          expect(json_response['data'][0]['relationships'].keys).not_to include('subjects')
        end
      end
    end

    describe 'recruitment cycle' do
      context 'when "current" is specified as the recruitment cycle' do
        before do
          create_list(:course, 3, provider:)

          get :index, params: {
            recruitment_cycle_year: 'current',
            provider_code: provider.provider_code
          }
        end

        it 'returns correct number of courses' do
          expect(json_response['data'].size).to be(3)
        end
      end

      context 'when a non-existent recruitment cycle is specified' do
        before do
          create_list(:course, 3, provider:)

          get :index, params: {
            recruitment_cycle_year: '1066',
            provider_code: provider.provider_code
          }
        end

        it 'returns the current recruitment cycle' do
          expect(json_response['data'].size).to be(3)
        end
      end
    end
  end

  describe '#show' do
    context 'when course exists' do
      let!(:course) { create(:course, provider:) }

      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code
        }
      end

      it 'returns the course' do
        expect(response).to be_successful
        expect(json_response['data']['id']).to eql(course.id.to_s)
      end
    end

    context 'with include' do
      let!(:course) do
        create(:course, :with_accrediting_provider, provider:)
      end

      let(:accredited_provider) { course.accrediting_provider }

      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: course.course_code,
          include: 'provider,accredited_body,recruitment_cycle'
        }
      end

      it 'returns the course with includes' do
        expect(response).to be_successful

        expect(json_response['data']['id']).to eql(course.id.to_s)

        expect(json_response['included'][0]['id']).to eql(accredited_provider.id.to_s)
        expect(json_response['included'][0]['type']).to eql('providers')

        expect(json_response['included'][1]['id']).to eql(provider.id.to_s)
        expect(json_response['included'][1]['type']).to eql('providers')
      end
    end

    context 'when course does not exist' do
      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: provider.provider_code,
          code: 'ABCD'
        }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when provider does not exist' do
      before do
        get :show, params: {
          recruitment_cycle_year: provider.recruitment_cycle.year,
          provider_code: 'ABC',
          code: 'ABCD'
        }
      end

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'recruitment cycle' do
      let!(:course) { create(:course, provider:) }

      context 'when "current" is specified as the recruitment cycle' do
        before do
          get :show, params: {
            recruitment_cycle_year: 'current',
            provider_code: provider.provider_code,
            code: course.course_code
          }
        end

        it 'returns the course' do
          expect(response).to be_successful
          expect(json_response['data']['id']).to eql(course.id.to_s)
        end
      end

      context 'when a non-existent recruitment cycle is specified' do
        before do
          get :show, params: {
            recruitment_cycle_year: '1066',
            provider_code: provider.provider_code,
            code: course.course_code
          }
        end

        it 'returns the course' do
          expect(response).to be_successful
          expect(json_response['data']['id']).to eql(course.id.to_s)
        end
      end
    end
  end
end
