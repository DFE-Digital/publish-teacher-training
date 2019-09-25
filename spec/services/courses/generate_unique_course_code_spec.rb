require "rails_helper"

describe Courses::GenerateUniqueCourseCodeService do
  let(:existing_codes) { [] }
  let(:mocked_gen_code_service) { double }
  let(:service) do
    described_class.new(
      existing_codes: existing_codes,
      generate_course_code_service: mocked_gen_code_service,
    )
  end

  describe "when there are no existing codes" do
    it 'calls "Courses::GenerateCourseCodeService" once' do
      expect(mocked_gen_code_service).to receive(:execute).once.and_return("A000")

      service.execute
    end
  end

  describe "when there is one existing code" do
    context "and we generate a different code" do
      let(:existing_codes) { %w[A111] }

      it 'calls "Courses::GenerateCourseCodeService" once' do
        expect(mocked_gen_code_service).to receive(:execute).once.and_return("A000")

        service.execute
      end
    end

    context "and we generate the same code first" do
      let(:existing_codes) { %w[A111] }

      it 'calls "Courses::GenerateCourseCodeService" twice' do
        expect(mocked_gen_code_service).to receive(:execute).twice.and_return("A111", "A000")

        service.execute
      end
    end
  end

  describe "when there are many existing codes" do
    let(:existing_codes) { %w[A111 X232 D268] }

    context "and the code generator generates the same codes" do
      it "still generates a new code" do
        expected_code = "B123"
        expect(mocked_gen_code_service).to receive(:execute).exactly(4)
                                                            .times
                                                            .and_return(*existing_codes, expected_code)
        expect(service.execute).to eq(expected_code)
      end
    end
  end
end
