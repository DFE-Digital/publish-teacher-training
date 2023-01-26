# frozen_string_literal: true

require "rails_helper"

module BigQuery
  describe EntityEvent do
    let(:event) { described_class.new }

    describe "#as_json" do
      subject { event.as_json }

      context "initialized" do
        it {  is_expected.to include("environment" => "test") }

        it "contains Time.now in iso8601" do
          Time.freeze do
            expected_time = Time.zone.now.iso8601
            expect(subject).to include("occurred_at" => expected_time)
          end
        end
      end

      context "with_type set" do
        %w[create_entity update_entity].each do |type|
          context "valid type - #{type}" do
            before do
              event.with_type(type)
            end

            let(:type) { type }

            it { is_expected.to include("event_type" => type) }
          end
        end

        context "invalid type" do
          let(:type) { "youre_fired" }

          it "raises" do
            expect { event.with_type(type) }.to raise_error(StandardError, "Invalid analytics event type")
          end
        end
      end

      context "with entity_table_name set" do
        let(:table_name) { "constable" }

        before do
          event.with_entity_table_name(table_name)
        end

        it { is_expected.to include("entity_table_name" => table_name) }
      end

      context "with_data set" do
        let(:data) do
          {
            one: "one",
            two: true,
            three: [1, 2, 3],
            four: { first: "test-one", second: "test-two" },
          }
        end

        let(:expected_data_key_value_pairs) do
          [
            { "key" => "one", "value" => ["one"] },
            { "key" => "two", "value" => ["true"] },
            { "key" => "three", "value" => ["[1,2,3]"] },
            { "key" => "four", "value" => ["{\"first\":\"test-one\",\"second\":\"test-two\"}"] },
          ]
        end

        before do
          event.with_data(data)
        end

        it { is_expected.to include("data" => expected_data_key_value_pairs) }
      end
    end
  end
end
