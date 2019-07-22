require "rails_helper"

describe 'PATCH /providers/:provider_code' do
  let(:jsonapi_renderer) { JSONAPI::Serializable::Renderer.new }
  let(:request_path) do
    "/api/v2/recruitment_cycles/#{recruitment_cycle.year}" +
      "/providers/#{provider.provider_code}"
  end

  def perform_request(provider)
    jsonapi_data = jsonapi_renderer.render(
      provider,
      class: {
        Provider: API::V2::SerializableProvider
      }
    )

    jsonapi_data.dig(:data, :attributes).slice!(*permitted_params)

    patch request_path,
          headers: { 'HTTP_AUTHORIZATION' => credentials },
          params: {
            _jsonapi: jsonapi_data
          }
  end

  let(:recruitment_cycle) { find_or_create :recruitment_cycle }
  let(:organisation) { create :organisation }
  let(:provider)     do
    create :provider,
           organisations: [organisation],
           recruitment_cycle: recruitment_cycle,
           enrichments: [enrichment]
  end
  let(:user)         { create :user, organisations: [organisation] }
  let(:payload)      { { email: user.email } }
  let(:token)        { build_jwt :apiv2, payload: payload }
  let(:enrichment)   { build(:provider_enrichment) }
  let(:update_enrichment) { build :provider_enrichment, **updated_attributes }
  # we need an unsaved provider to add the enrichment to (so that it isn't
  # persisted)
  let(:update_provider) { provider.dup.tap { |p| p.enrichments << update_enrichment } }
  let(:site) { build(:site) }

  let(:credentials) do
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  let(:updated_attributes) do
    {
      email: 'Email',
      website: 'Website',
      address1: 'Address1',
      address2: 'Address2',
      address3: 'Address3',
      address4: 'Address4',
      postcode: 'Postcode',
      region_code: 'RegionCode',
      telephone: 'Telephone',
      train_with_us: 'TrainWithUs',
      train_with_disability: 'TrainWithDisability'
    }
  end
  let(:permitted_params) do
    %i[
      email
      website
      address1
      address2
      address3
      address4
      postcode
      region_code
      telephone
      train_with_us
      train_with_disability
    ]
  end

  describe 'with unpermitted attributes on provider object' do
    shared_examples 'does not allow assignment' do |attribute, value|
      it "doesn't permit #{attribute}" do
        update_provider = build(:provider, attribute => value, sites: [site])
        update_provider.id = provider.id
        perform_request(provider)
        expect(provider.reload.send(attribute)).not_to eq(value)
      end
    end

    include_examples 'does not allow assignment', :email, 'email@email.com'
    include_examples 'does not allow assignment', :website, 'www.website.com'
    include_examples 'does not allow assignment', :address1, 'number'
    include_examples 'does not allow assignment', :address2, 'road'
    include_examples 'does not allow assignment', :address3, 'town'
    include_examples 'does not allow assignment', :address4, 'county'
    include_examples 'does not allow assignment', :postcode, 'postcode'
    include_examples 'does not allow assignment', :region_code, 1
    include_examples 'does not allow assignment', :telephone, '01234 567890'
    include_examples 'does not allow assignment', :train_with_us, 'TrainWithUs'
    include_examples 'does not allow assignment', :train_with_disability, 'TrainWithDisability'

  #
  #   it "doesn't allow updating of provider" do
  #     another_provider = create(:provider)
  #     update_course    = build(
  #       :course,
  #       provider_id: another_provider.id,
  #       provider:    provider
  #     )
  #     update_course.id = course.id
  #
  #     perform_request(course)
  #
  #     expect(course.reload.provider_id).not_to eq(another_provider.id)
  #   end
  #
  #   it "doesn't allow updating of accrediting provider" do
  #     another_provider = create(:provider)
  #     update_course    = build(
  #       :course,
  #       accrediting_provider: another_provider,
  #       provider:             provider
  #     )
  #     update_course.id = course.id
  #
  #     perform_request(course)
  #
  #     expect(course.reload.accrediting_provider).not_to eq(another_provider)
  #   end
  # end
  #
  # context 'course has no enrichments' do
  #   it "creates a draft enrichment for the course" do
  #     expect {
  #       perform_request update_course
  #     }.to(change {
  #            course.reload.enrichments.count
  #          }.from(0).to(1))
  #
  #     draft_enrichment = course.enrichments.draft.first
  #     expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
  #       .to include(updated_attributes.stringify_keys)
  #   end
  #
  #   it "change content status" do
  #     expect {
  #       perform_request update_course
  #     }.to(change { course.reload.content_status }.from(:empty).to(:draft))
  #   end
  #
  #   context "with no attributes to update" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: nil,
  #         course_length: nil,
  #         fee_details: nil,
  #         fee_international: nil,
  #         fee_uk_eu: nil,
  #         financial_support: nil,
  #         how_school_placements_work: nil,
  #         interview_process: nil,
  #         other_requirements: nil,
  #         personal_qualities: nil,
  #         qualifications: nil,
  #         salary_details: nil
  #       }
  #     end
  #
  #     it "doesn't create a draft enrichment" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.enrichments.count })
  #     end
  #   end
  #
  #   context "with empty attributes" do
  #     let(:permitted_params) { [] }
  #
  #     it "doesn't create a draft enrichment" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.enrichments.count })
  #     end
  #
  #     it "doesn't change content status" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.content_status })
  #     end
  #   end
  #
  #   it 'returns ok' do
  #     perform_request update_course
  #
  #     expect(response).to be_ok
  #   end
  #
  #   it 'returns the updated course' do
  #     perform_request update_course
  #     json_response = JSON.parse(response.body)['data']
  #
  #     expect(json_response).to have_id(course.id.to_s)
  #     expect(json_response).to have_type('courses')
  #     expect(json_response).to have_attribute(:about_course)
  #       .with_value('new about course')
  #     expect(json_response).to have_attribute(:course_length)
  #       .with_value('new course length')
  #     expect(json_response).to have_attribute(:fee_details)
  #       .with_value('new fee details')
  #     expect(json_response).to have_attribute(:fee_international)
  #       .with_value(0)
  #     expect(json_response).to have_attribute(:fee_uk_eu)
  #       .with_value(0)
  #     expect(json_response).to have_attribute(:financial_support)
  #       .with_value('new financial support')
  #     expect(json_response).to have_attribute(:how_school_placements_work)
  #       .with_value('new how school placements work')
  #     expect(json_response).to have_attribute(:interview_process)
  #       .with_value('new interview process')
  #     expect(json_response).to have_attribute(:other_requirements)
  #       .with_value('new other requirements')
  #     expect(json_response).to have_attribute(:personal_qualities)
  #       .with_value('new personal qualities')
  #     expect(json_response).to have_attribute(:required_qualifications)
  #       .with_value('new required qualifications')
  #     expect(json_response).to have_attribute(:salary_details)
  #       .with_value('new salary details')
  #     expect(json_response).to have_attribute(:content_status)
  #       .with_value('draft')
  #   end
  # end
  #
  # context 'course has no enrichments and is in the next recruitment cycle' do
  #   let(:recruitment_cycle) { create :recruitment_cycle, :next }
  #
  #   it "creates a draft enrichment for the course" do
  #     expect {
  #       perform_request update_course
  #     }.to(change {
  #            course.reload.enrichments.count
  #          }.from(0).to(1))
  #
  #     draft_enrichment = course.enrichments.draft.first
  #     expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
  #       .to include(updated_attributes.stringify_keys)
  #   end
  #
  #   it "change content status" do
  #     expect {
  #       perform_request update_course
  #     }.to(change { course.reload.content_status }.from(:rolled_over).to(:draft))
  #   end
  #
  #   context "with no attributes to update" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: nil,
  #         course_length: nil,
  #         fee_details: nil,
  #         fee_international: nil,
  #         fee_uk_eu: nil,
  #         financial_support: nil,
  #         how_school_placements_work: nil,
  #         interview_process: nil,
  #         other_requirements: nil,
  #         personal_qualities: nil,
  #         qualifications: nil,
  #         salary_details: nil
  #       }
  #     end
  #
  #     it "doesn't create a draft enrichment" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.enrichments.count })
  #     end
  #   end
  #
  #   context "with empty attributes" do
  #     let(:permitted_params) { [] }
  #
  #     it "doesn't create a draft enrichment" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.enrichments.count })
  #     end
  #
  #     it "doesn't change content status" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.content_status })
  #     end
  #   end
  #
  #   it 'returns ok' do
  #     perform_request update_course
  #
  #     expect(response).to be_ok
  #   end
  #
  #   it 'returns the updated course' do
  #     perform_request update_course
  #     json_response = JSON.parse(response.body)['data']
  #
  #     expect(json_response).to have_id(course.id.to_s)
  #     expect(json_response).to have_type('courses')
  #     expect(json_response).to have_attribute(:about_course)
  #       .with_value('new about course')
  #     expect(json_response).to have_attribute(:course_length)
  #       .with_value('new course length')
  #     expect(json_response).to have_attribute(:fee_details)
  #       .with_value('new fee details')
  #     expect(json_response).to have_attribute(:fee_international)
  #       .with_value(0)
  #     expect(json_response).to have_attribute(:fee_uk_eu)
  #       .with_value(0)
  #     expect(json_response).to have_attribute(:financial_support)
  #       .with_value('new financial support')
  #     expect(json_response).to have_attribute(:how_school_placements_work)
  #       .with_value('new how school placements work')
  #     expect(json_response).to have_attribute(:interview_process)
  #       .with_value('new interview process')
  #     expect(json_response).to have_attribute(:other_requirements)
  #       .with_value('new other requirements')
  #     expect(json_response).to have_attribute(:personal_qualities)
  #       .with_value('new personal qualities')
  #     expect(json_response).to have_attribute(:required_qualifications)
  #       .with_value('new required qualifications')
  #     expect(json_response).to have_attribute(:salary_details)
  #       .with_value('new salary details')
  #     expect(json_response).to have_attribute(:content_status)
  #       .with_value('draft')
  #   end
  # end
  #
  # context 'course has a draft enrichment' do
  #   let(:enrichment) { build :course_enrichment }
  #   let(:course) do
  #     create :course, provider: provider, enrichments: [enrichment]
  #   end
  #
  #   it "updates the course's draft enrichment" do
  #     expect {
  #       perform_request update_course
  #     }.not_to(
  #       change { course.enrichments.reload.count }
  #     )
  #
  #     draft_enrichment = course.enrichments.draft.first
  #     expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
  #       .to include(updated_attributes.stringify_keys)
  #   end
  #
  #   it "doesn't change content status" do
  #     expect {
  #       perform_request update_course
  #     }.to_not(change { course.reload.content_status })
  #   end
  #
  #   context "with invalid data" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: Faker::Lorem.sentence(1000),
  #         fee_details: Faker::Lorem.sentence(1000),
  #         fee_international: 200_000,
  #         fee_uk_eu: 200_000,
  #         financial_support: Faker::Lorem.sentence(1000),
  #         how_school_placements_work: Faker::Lorem.sentence(1000),
  #         interview_process: Faker::Lorem.sentence(1000),
  #         other_requirements: Faker::Lorem.sentence(1000),
  #         personal_qualities: Faker::Lorem.sentence(1000),
  #         qualifications: Faker::Lorem.sentence(1000),
  #         salary_details: Faker::Lorem.sentence(1000)
  #       }
  #     end
  #
  #     subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }
  #
  #     it "returns validation errors" do
  #       perform_request update_course
  #
  #       expect("Invalid about_course".in?(subject)).to eq(true)
  #       expect("Invalid interview_process".in?(subject)).to eq(true)
  #       expect("Invalid how_school_placements_work".in?(subject)).to eq(true)
  #       expect("Invalid qualifications".in?(subject)).to eq(true)
  #       expect("Invalid fee_details".in?(subject)).to eq(true)
  #       expect("Invalid financial_support".in?(subject)).to eq(true)
  #     end
  #   end
  #
  #   context "with nil data" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: "",
  #         fee_details: "",
  #         fee_international: 0,
  #         fee_uk_eu: 0,
  #         financial_support: "",
  #         how_school_placements_work: "",
  #         interview_process: "",
  #         other_requirements: "",
  #         personal_qualities: "",
  #         qualifications: "",
  #         salary_details: ""
  #       }
  #     end
  #
  #     it "returns ok" do
  #       perform_request update_course
  #
  #       expect(response).to be_ok
  #     end
  #
  #     it "doesn't change content status" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.content_status })
  #     end
  #   end
  # end
  #
  # context 'course has only a published enrichment' do
  #   let(:enrichment) { build :course_enrichment, :published }
  #   let(:course) do
  #     create :course, provider: provider, enrichments: [enrichment]
  #   end
  #
  #   it "creates a draft enrichment for the course" do
  #     expect { perform_request update_course }
  #       .to(
  #         change { course.enrichments.reload.draft.count }
  #           .from(0).to(1)
  #       )
  #
  #     draft_enrichment = course.enrichments.draft.first
  #     expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
  #       .to include(updated_attributes.stringify_keys)
  #   end
  #
  #   it do
  #     expect { perform_request update_course }
  #     .to(
  #       change { course.enrichments.reload.count }
  #         .from(1).to(2)
  #     )
  #   end
  #
  #   it "change content status" do
  #     expect {
  #       perform_request update_course
  #     }.to(change { course.reload.content_status }.from(:published).to(:published_with_unpublished_changes))
  #   end
  #
  #   context "with invalid data" do
  #     let(:updated_attributes) do
  #       { about_course: Faker::Lorem.sentence(1000) }
  #     end
  #
  #     subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }
  #
  #     it "returns validation errors" do
  #       perform_request update_course
  #
  #       expect("Invalid enrichments".in?(subject)).to eq(false)
  #       expect("Invalid about_course".in?(subject)).to eq(true)
  #     end
  #   end
  # end
  #
  # context 'course has a rolled-over enrichment' do
  #   let(:enrichment) { build :course_enrichment, :rolled_over }
  #   let(:course) do
  #     create :course, provider: provider, enrichments: [enrichment]
  #   end
  #
  #   it "updates the course's draft enrichment" do
  #     expect {
  #       perform_request update_course
  #     }.not_to(
  #       change { course.enrichments.reload.count }
  #     )
  #
  #     draft_enrichment = course.enrichments.draft.first
  #     expect(draft_enrichment.attributes.slice(*updated_attributes.keys.map(&:to_s)))
  #       .to include(updated_attributes.stringify_keys)
  #   end
  #
  #   it "changes the content status to draft" do
  #     expect {
  #       perform_request update_course
  #     }.to(
  #       change { course.reload.content_status }
  #         .from(:rolled_over).to(:draft)
  #     )
  #   end
  #
  #   context "with invalid data" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: Faker::Lorem.sentence(1000),
  #         fee_details: Faker::Lorem.sentence(1000),
  #         fee_international: 200_000,
  #         fee_uk_eu: 200_000,
  #         financial_support: Faker::Lorem.sentence(1000),
  #         how_school_placements_work: Faker::Lorem.sentence(1000),
  #         interview_process: Faker::Lorem.sentence(1000),
  #         other_requirements: Faker::Lorem.sentence(1000),
  #         personal_qualities: Faker::Lorem.sentence(1000),
  #         qualifications: Faker::Lorem.sentence(1000),
  #         salary_details: Faker::Lorem.sentence(1000)
  #       }
  #     end
  #
  #     subject { JSON.parse(response.body)["errors"].map { |e| e["title"] } }
  #
  #     it "returns validation errors" do
  #       perform_request update_course
  #
  #       expect("Invalid about_course".in?(subject)).to eq(true)
  #       expect("Invalid interview_process".in?(subject)).to eq(true)
  #       expect("Invalid how_school_placements_work".in?(subject)).to eq(true)
  #       expect("Invalid qualifications".in?(subject)).to eq(true)
  #       expect("Invalid fee_details".in?(subject)).to eq(true)
  #       expect("Invalid financial_support".in?(subject)).to eq(true)
  #     end
  #
  #     it "doesn't change content status" do
  #       expect {
  #         perform_request update_course
  #       }.to_not(change { course.reload.content_status })
  #     end
  #   end
  #
  #   context "with nil data" do
  #     let(:updated_attributes) do
  #       {
  #         about_course: "",
  #         fee_details: "",
  #         fee_international: 0,
  #         fee_uk_eu: 0,
  #         financial_support: "",
  #         how_school_placements_work: "",
  #         interview_process: "",
  #         other_requirements: "",
  #         personal_qualities: "",
  #         qualifications: "",
  #         salary_details: ""
  #       }
  #     end
  #
  #     it "returns ok" do
  #       perform_request update_course
  #
  #       expect(response).to be_ok
  #     end
  #
  #     it "changes the content status to draft" do
  #       expect {
  #         perform_request update_course
  #       }.to(
  #         change { course.reload.content_status }
  #           .from(:rolled_over).to(:draft)
  #       )
  #     end
  #   end
  # end
  #
  # describe 'from published to draft' do
  #   shared_examples 'only one attribute has changed' do |attribute_key, attribute_value, jsonapi_serialized_name|
  #     describe 'a subsequent draft enrichment is added' do
  #       let(:updated_attributes) do
  #         attribute = {}
  #         attribute[attribute_key] = attribute_value
  #         attribute
  #       end
  #
  #       let(:permitted_params) {
  #         if jsonapi_serialized_name.blank?
  #           [attribute_key]
  #         else
  #           [jsonapi_serialized_name]
  #         end
  #       }
  #
  #       before do
  #         perform_request update_course
  #       end
  #
  #       subject {
  #         course.reload
  #       }
  #
  #       its(:content_status) { should eq :published_with_unpublished_changes }
  #
  #       it "set #{attribute_key}" do
  #         expect(subject.enrichments.draft.first[attribute_key]).to eq(attribute_value)
  #       end
  #
  #       enrichments_attributes_key = %i[
  #         about_course
  #         fee_details
  #         fee_international
  #         fee_uk_eu
  #         financial_support
  #         how_school_placements_work
  #         interview_process
  #         other_requirements
  #         personal_qualities
  #         qualifications
  #         salary_details
  #       ].freeze
  #
  #       published_enrichment_attributes = (enrichments_attributes_key.filter { |x| x != attribute_key }).freeze
  #
  #       published_enrichment_attributes.each do |published_enrichment_attribute|
  #         it "set #{published_enrichment_attribute} using published enrichment" do
  #           expect(subject.enrichments.draft.first[published_enrichment_attribute]).to eq(original_enrichment[published_enrichment_attribute])
  #         end
  #       end
  #     end
  #   end
  #
  #   let(:original_enrichment) { build :course_enrichment, :published }
  #   let(:course) do
  #     create :course, provider: provider, enrichments: [original_enrichment]
  #   end
  #
  #   include_examples 'only one attribute has changed', :fee_details, 'changed fee_details'
  #   include_examples 'only one attribute has changed', :fee_international, 666
  #   include_examples 'only one attribute has changed', :fee_uk_eu, 999
  #   include_examples 'only one attribute has changed', :financial_support, 'changed financial_support'
  #   include_examples 'only one attribute has changed', :how_school_placements_work, 'changed how_school_placements_work'
  #   include_examples 'only one attribute has changed', :interview_process, 'changed interview_process'
  #   include_examples 'only one attribute has changed', :other_requirements, 'changed other_requirements'
  #   include_examples 'only one attribute has changed', :personal_qualities, 'changed personal_qualities'
  #   include_examples 'only one attribute has changed', :qualifications, 'changed qualifications', :required_qualifications
  #   include_examples 'only one attribute has changed', :salary_details, 'changed salary_details'
  end
end
