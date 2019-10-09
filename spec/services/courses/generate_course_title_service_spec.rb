require "rails_helper"

describe Courses::GenerateCourseTitleService do
  let(:service) { described_class.new }
  let(:subjects) { [] }
  let(:is_send) { false }
  let(:level) { "primary" }
  let(:course) { Course.new(level: level, subjects: subjects, is_send: is_send) }
  let(:modern_languages) { create(:subject, subject_name: "Modern Languages", type: :SecondarySubject).becomes(SecondarySubject) }
  let(:generated_title) { service.execute(course: course) }

  before { modern_languages }

  shared_examples "with SEND" do
    context "With SEND" do
      let(:is_send) { true }

      it "Appends SEND information to the title" do
        expect(generated_title).to end_with("with Special educational needs and disability")
      end
    end
  end

  context "With no subjects" do
    it "Returns an empty string" do
      expect(generated_title).to eq("")
    end
  end

  context "Generating a title for a further education course" do
    let(:level) { "further_education" }

    it "returns 'Further education'" do
      expect(generated_title).to eq("Further education")
    end

    include_examples "with SEND"
  end

  context "Generating a title for non-further education course" do
    let(:level) { "primary" }

    context "With a single subject" do
      let(:subjects) { [Subject.new(subject_name: "Physics")] }
      it "Returns the subject name" do
        expect(generated_title).to eq("Physics")
      end

      include_examples "with SEND"
    end

    context "With multiple subjects" do
      let(:subjects) { [Subject.new(subject_name: "English"), Subject.new(subject_name: "Physics")] }

      it "Returns a name containing both subjects" do
        expect(generated_title).to eq("English with Physics")
      end

      include_examples "with SEND"
    end

    context "With modern languages" do
      context "with one language" do
        let(:subjects) { [modern_languages, Subject.new(subject_name: "French")] }

        it "Returns a name modern language with language" do
          expect(generated_title).to eq("Modern Languages (French)")
        end

        include_examples "with SEND"
      end

      context "with two languages" do
        let(:subjects) do
          [
            modern_languages,
            Subject.new(subject_name: "French"),
            Subject.new(subject_name: "German"),
          ]
        end

        it "Returns a name modern language with both languages" do
          expect(generated_title).to eq("Modern Languages (French and German)")
        end

        include_examples "with SEND"
      end

      context "with three languages" do
        let(:subjects) do
          [
            modern_languages,
            Subject.new(subject_name: "French"),
            Subject.new(subject_name: "German"),
            Subject.new(subject_name: "Japanese"),
          ]
        end

        it "Returns a name modern language with three languages" do
          expect(generated_title).to eq("Modern Languages (French, German, Japanese)")
        end

        include_examples "with SEND"
      end

      context "with four or more languages" do
        let(:subjects) do
          [
            modern_languages,
            Subject.new(subject_name: "French"),
            Subject.new(subject_name: "German"),
            Subject.new(subject_name: "Japanese"),
            Subject.new(subject_name: "Spanish"),
          ]
        end

        it "Returns just modern languages" do
          expect(generated_title).to eq("Modern Languages")
        end

        include_examples "with SEND"
      end
    end
  end
end
