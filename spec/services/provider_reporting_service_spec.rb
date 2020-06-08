require "rails_helper"

describe ProviderReportingService do
  let(:closed_providers_scope) { class_double(Provider) }
  let(:closed_providers_accrediting_provider_scope) { class_double(Provider) }
  let(:closed_providers_provider_type_scope) { class_double(Provider) }
  let(:closed_providers_region_code_scope) { class_double(Provider) }

  let(:providers_scope) { class_double(Provider) }
  let(:training_providers_scope) { class_double(Provider) }

  let(:open_providers_scope) { class_double(Provider) }
  let(:open_providers_accrediting_provider_scope) { class_double(Provider) }
  let(:open_providers_provider_type_scope) { class_double(Provider) }
  let(:open_providers_region_code_scope) { class_double(Provider) }

  let(:distinct_providers_scope) { class_double(Provider) }

  let(:providers_count) { 100 }
  let(:training_providers_count) { 60 }
  let(:open_providers_count) { 40 }
  let(:closed_providers_count) { 20 }

  let(:expected) do
    {
      total: {
        all: providers_count,
        non_training_providers: providers_count - training_providers_count,
        training_providers: training_providers_count,
      },
      training_providers: {
        findable_total: {
          open: open_providers_count,
          closed: closed_providers_count,
        },
        accredited_body: {
          open: {
            accredited_body: 1,
            not_an_accredited_body: 2,
          },
          closed: {
            accredited_body: 0,
            not_an_accredited_body: 0,
          },
        },
        provider_type: {
          open: {
            scitt: 1, lead_school: 2, university: 3, unknown: 4, invalid_value: 5
          },
          closed: {
            scitt: 0, lead_school: 0, university: 0, unknown: 0, invalid_value: 0
          },
        },
        region_code: {
          open: {
            no_region: 0,
            london: 1,
            south_east: 2,
            south_west: 3,
            wales: 4,
            west_midlands: 5,
            east_midlands: 6,
            eastern: 7,
            north_west: 8,
            yorkshire_and_the_humber: 9,
            north_east: 10,
            scotland: 12,
          },
          closed: {
            no_region: 0,
            london: 0,
            south_east: 0,
            south_west: 0,
            wales: 0,
            west_midlands: 0,
            east_midlands: 0,
            eastern: 0,
            north_west: 0,
            yorkshire_and_the_humber: 0,
            north_east: 0,
            scotland: 0,
          },
        },
      },
    }
  end

  describe ".call" do
    describe "when scope is passed" do
      subject { described_class.call(providers_scope: providers_scope) }

      it "applies the scopes" do
        expect(providers_scope).to receive_message_chain(:distinct).and_return(distinct_providers_scope)
        expect(distinct_providers_scope).to receive_message_chain(:count).and_return(providers_count)
        expect(distinct_providers_scope).to receive_message_chain(:count).and_return(providers_count)
        expect(distinct_providers_scope).to receive_message_chain(:where).with(id: Course.findable.select(:provider_id)).and_return(training_providers_scope)

        expect(distinct_providers_scope).to receive_message_chain(:where)
          .with(id: Course.findable.with_vacancies.select(:provider_id))
          .and_return(open_providers_scope)

        expect(training_providers_scope).to receive_message_chain(:where, :not).and_return(closed_providers_scope)

        expect(training_providers_scope).to receive_message_chain(:count).and_return(training_providers_count)
        expect(training_providers_scope).to receive_message_chain(:count).and_return(training_providers_count)
        expect(open_providers_scope).to receive_message_chain(:count).and_return(open_providers_count)

        expect(open_providers_scope).to receive_message_chain(:group)
          .with(:accrediting_provider)
          .and_return(open_providers_accrediting_provider_scope)

        expect(open_providers_accrediting_provider_scope).to receive_message_chain(:count)
          .and_return(
            { "accredited_body" => 1, "not_an_accredited_body" => 2 },
          )

        expect(open_providers_scope).to receive_message_chain(:group).with(:provider_type).and_return(open_providers_provider_type_scope)
        expect(open_providers_provider_type_scope).to receive_message_chain(:count)
          .and_return(
            { "scitt" => 1, "lead_school" => 2, "university" => 3, "unknown" => 4, "invalid_value" => 5 },
          )

        expect(open_providers_scope).to receive_message_chain(:group).with(:region_code).and_return(open_providers_region_code_scope)
        expect(open_providers_region_code_scope).to receive_message_chain(:count)
          .and_return(
            {
              "no_region" => 0,
              "london" => 1,
              "south_east" => 2,
              "south_west" => 3,
              "wales" => 4,
              "west_midlands" => 5,
              "east_midlands" => 6,
              "eastern" => 7,
              "north_west" => 8,
              "yorkshire_and_the_humber" => 9,
              "north_east" => 10,
              "scotland" => 12,
            },
          )

        expect(closed_providers_scope).to receive_message_chain(:count).and_return(closed_providers_count)

        expect(closed_providers_scope).to receive_message_chain(:group).with(:accrediting_provider).and_return(closed_providers_accrediting_provider_scope)
        expect(closed_providers_accrediting_provider_scope).to receive_message_chain(:count).and_return({})

        expect(closed_providers_scope).to receive_message_chain(:group).with(:provider_type).and_return(closed_providers_provider_type_scope)
        expect(closed_providers_provider_type_scope).to receive_message_chain(:count).and_return({})

        expect(closed_providers_scope).to receive_message_chain(:group).with(:region_code).and_return(closed_providers_region_code_scope)
        expect(closed_providers_region_code_scope).to receive_message_chain(:count).and_return({})

        expect(subject).to eq(expected)
      end
    end
  end
end
