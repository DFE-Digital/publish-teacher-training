describe "Courses API", type: :request do

  def get_course_codes_from_body(body)
    json = JSON.parse(body)
    json.map { |course| course["course_code"] }
  end

  describe 'GET index' do
    let(:credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('bats')
    end
    let(:unauthorized_credentials) do
      ActionController::HttpAuthentication::Token
        .encode_credentials('foo')
    end

    context 'with multiple recruitment cycles' do
      describe 'JSON body response' do
        let(:provider) { create(:provider, courses: [course]) }
        let(:course) { build(:course) }
        let(:provider2) { create(:provider, :next_recruitment_cycle, courses: [course2]) }
        let(:course2) { build(:course) }

        before do
          provider
          provider2
          get_index
        end

        context 'with no cycle specified in the route' do
          let(:get_index) { get '/api/v1/courses', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'defaults to the current cycle when year' do
            returned_course_codes = get_course_codes_from_body(response.body)
            expect(returned_course_codes).not_to include course2.course_code
            expect(returned_course_codes).to include course.course_code
          end
        end
        context 'with a future recruitment cycle specified in the route' do
          let(:get_index) { get '/api/v1/2020/courses', headers: { 'HTTP_AUTHORIZATION' => credentials } }

          it 'only returns courses from the requested cycle' do
            returned_course_codes = get_course_codes_from_body(response.body)

            expect(returned_course_codes).to include course2.course_code
            expect(returned_course_codes).not_to include course.course_code
          end
        end
      end
    end
  end
end
