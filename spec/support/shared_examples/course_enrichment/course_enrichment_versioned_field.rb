# frozen_string_literal: true

# Usage:
#   it_behaves_like "versioned_presence_field",
#                   field: :about_course,
#                   required_in: { 1 => true, 2 => false },
#                   word_limit: 400
#
#   it_behaves_like "versioned_presence_field",
#                   field: :describe_school,
#                   required_in: { 1 => false, 2 => true },
#                   word_limit: [400, 100] -> Means 400 words in v1 and 100 in v2
#
# Optional keys:
#   :conditional  -> lambda that returns true/false to gate requirement (e.g. only for fee courses)
#
RSpec.shared_examples "versioned_presence_field" do |field:, required_in:, word_limit: nil, conditional: nil|
  [1, 2].each do |ver|
    context "version #{ver}" do
      let(:version) { ver }
      let(:course)  { build(:course,funding: "fee") }
      let(:record)  { build(:course_enrichment, "v#{ver}".to_sym, course:) }

      context "presence_field" do
        before { record.public_send("#{field}=", nil) }
        required = required_in.fetch(ver)

        it ":#{field} #{required ? 'is' : 'is not'} required on publish (v#{ver})" do
          valid = record.valid?(:publish)

          if required_in[version] && (conditional ? conditional.call(record) : true)
            expect(valid).to be(false)
          else
            expect(valid).to be(true)
            expect(record.errors[field]).to be_empty
          end
        end

        it "is allowed to be nil when not publishing" do
          expect(record).to be_valid
        end
      end

      if word_limit
        context "word over limit of #{word_limit}" do
          before do
            if word_limit.is_a?(Array)
              over = Faker::Lorem.words(number: word_limit[version - 1] + 1).join(" ")
            else
              over = Faker::Lorem.words(number: word_limit + 1).join(" ")
            end
            record.public_send("#{field}=", over)
          end

          it "adds an error if exceeded" do
            expect(record).not_to be_valid
            expect(record.errors[field]).to be_present
          end
        end

        context "word at limit of #{word_limit}" do
          before do
            if word_limit.is_a?(Array)
              words = Faker::Lorem.words(number: word_limit[version - 1]).join(" ")
            else
              words = Faker::Lorem.words(number: word_limit).join(" ")
            end
            record.public_send("#{field}=", words)
          end

          it "Under the word limit" do
            expect(record).to be_valid
          end
        end
      end
    end
  end
end