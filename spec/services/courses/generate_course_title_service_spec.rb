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
      let(:subjects) { [Subject.new(subject_name: "Physical education")] }
      it "Returns the subject name" do
        expect(generated_title).to eq("Physical education")
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
        let(:subjects) { [modern_languages, create(:subject, :french)] }

        it "Returns a name modern language with language" do
          expect(generated_title).to eq("Modern Languages (French)")
        end

        include_examples "with SEND"
      end

      context "with two languages" do
        let(:subjects) do
          [
            modern_languages,
            create(:subject, :french),
            create(:subject, :german),
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
            create(:subject, :french),
            create(:subject, :german),
            create(:subject, :japanese),
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
            create(:subject, :french),
            create(:subject, :german),
            create(:subject, :japanese),
            create(:subject, :spanish),
          ]
        end

        it "Returns just modern languages" do
          expect(generated_title).to eq("Modern Languages")
        end

        include_examples "with SEND"
      end
    end

    context "Names which require altering" do
      context "Communications and media studies" do
        context "With single subject" do
          let(:subjects) do
            [create(:subject, :communication_and_media_studies)]
          end

          it "Returns the title Media studies" do
            expect(generated_title).to eq("Media studies")
          end
        end

        context "With multiple subjects" do
          let(:subjects) do
            [
              create(:subject, :communication_and_media_studies),
              create(:subject, :mathematics),
            ]
          end

          it "Returns the title Media studies" do
            expect(generated_title).to eq("Media studies with Mathematics")
          end
        end
      end


      context "English as a second language" do
        context "With a single language" do
          let(:subjects) do
            [modern_languages, create(:subject, :english_as_a_second_language)]
          end

          it "Returns the title Modern Languages (English)" do
            expect(generated_title).to eq("Modern Languages (English)")
          end
        end

        context "With two languages" do
          let(:subjects) do
            [
              modern_languages,
              create(:subject, :english_as_a_second_language),
              create(:subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (English and Spanish)" do
            expect(generated_title).to eq("Modern Languages (English and Spanish)")
          end
        end

        context "With three languages" do
          let(:subjects) do
            [
              modern_languages,
              create(:subject, :english_as_a_second_language),
              create(:subject, :french),
              create(:subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (English, French, Spanish)" do
            expect(generated_title).to eq("Modern Languages (English, French, Spanish)")
          end
        end
      end

      context "Modern Languages (Other)" do
        context "With a single language" do
          let(:subjects) do
            [modern_languages, create(:subject, :modern_languages_other)]
          end

          it "Returns the title Modern Languages (Other)" do
            expect(generated_title).to eq("Modern Languages (Other)")
          end
        end

        context "With two languages" do
          let(:subjects) do
            [
              modern_languages,
              create(:subject, :modern_languages_other),
              create(:subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (Other and Spanish)" do
            expect(generated_title).to eq("Modern Languages (Other and Spanish)")
          end
        end

        context "With three languages" do
          let(:subjects) do
            [
              modern_languages,
              create(:subject, :modern_languages_other),
              create(:subject, :french),
              create(:subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (Other, French, Spanish)" do
            expect(generated_title).to eq("Modern Languages (Other, French, Spanish)")
          end
        end
      end
    end
  end
end
