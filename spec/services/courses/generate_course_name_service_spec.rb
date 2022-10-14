require "rails_helper"

describe Courses::GenerateCourseNameService do
  let(:service) { described_class.new }
  let(:subjects) { [] }
  let(:is_send) { false }
  let(:level) { "primary" }
  let(:campaign_name) { "no_campaign" }
  let(:course) { Course.new(level:, subjects:, is_send:, campaign_name:) }
  let(:modern_languages) { find_or_create(:secondary_subject, :modern_languages) }
  let(:generated_title) { service.execute(course:) }

  before do
    SecondarySubject.clear_cache
    modern_languages
  end

  shared_examples "with SEND" do
    context "With SEND" do
      let(:is_send) { true }

      it "Appends SEND information to the title" do
        expect(generated_title).to end_with(" (SEND)")
      end
    end
  end

  describe "Engineers Teach Physics" do
    context "With no campaign" do
      let(:subjects) { [SecondarySubject.find_by(subject_name: "Physics")] }
      let(:course) { create(:course, master_subject_id: 29) }
# create course with assoc subject
      it "returns Physics" do
        binding.pry
        expect(generated_title).to eq("Physics")
      end

      include_examples "with SEND"
    end

    context "With engineers_teach_physics campaign" do
      let(:campaign_name) { "engineers_teach_physics" }
      let(:subjects) { [SecondarySubject.find_by(subject_name: "Physics")] }
      let(:course) { Course.new(level:, subjects:, is_send:, campaign_name:, master_subject_id: 29) }

      it "returns Engineers Teach Physics" do
        binding.pry
        expect(generated_title).to eq("Engineers Teach Physics")
      end

      include_examples "with SEND"
    end

    context "With campaign and second subject" do
      let(:campaign_name) { "engineers_teach_physics" }
      let(:subjects) { [find_or_create(:secondary_subject, :physics), find_or_create(:secondary_subject, :english)] }
      let(:course) { Course.new(level:, subjects:, is_send:, campaign_name:, master_subject_id: 29) }

      it "returns Engineers Teach Physics with subject" do
        expect(generated_title).to eq("Engineers Teach Physics with English")
      end

      include_examples "with SEND"
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
      let(:subjects) { [find_or_create(:secondary_subject, :physics), find_or_create(:secondary_subject, :english)] }

      it "Returns a name containing both subjects in the order they were given" do
        expect(generated_title).to eq("Physics with English")
      end

      include_examples "with SEND"
    end

    context "With modern languages" do
      context "with one language" do
        let(:subjects) { [modern_languages, find_or_create(:modern_languages_subject, :french)] }

        it "Returns a name modern language with language" do
          expect(generated_title).to eq("Modern Languages (French)")
        end

        include_examples "with SEND"
      end

      context "with two languages" do
        let(:subjects) do
          [
            modern_languages,
            find_or_create(:modern_languages_subject, :french),
            find_or_create(:modern_languages_subject, :german),
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
            find_or_create(:modern_languages_subject, :french),
            find_or_create(:modern_languages_subject, :german),
            find_or_create(:modern_languages_subject, :japanese),
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
            find_or_create(:modern_languages_subject, :french),
            find_or_create(:modern_languages_subject, :german),
            find_or_create(:modern_languages_subject, :japanese),
            find_or_create(:modern_languages_subject, :spanish),
          ]
        end

        it "Returns just modern languages" do
          expect(generated_title).to eq("Modern Languages")
        end

        include_examples "with SEND"
      end
    end

    context "Names which require altering" do
      context "Communications and media studies -> Media studies" do
        context "With single subject" do
          let(:subjects) do
            [find_or_create(:secondary_subject, :communication_and_media_studies)]
          end

          it "Returns the title Media studies" do
            expect(generated_title).to eq("Media studies")
          end
        end

        context "With multiple subjects" do
          let(:subjects) do
            [
              find_or_create(:secondary_subject, :communication_and_media_studies),
              find_or_create(:secondary_subject, :mathematics),
            ]
          end

          it "Returns the title Media studies" do
            expect(generated_title).to eq("Media studies with Mathematics")
          end
        end
      end

      context "English as a second language -> English" do
        context "With a single language" do
          let(:subjects) do
            [modern_languages, find_or_create(:modern_languages_subject, :english_as_a_second_language_or_other_language)]
          end

          it "Returns the title Modern Languages (English)" do
            expect(generated_title).to eq("Modern Languages (English)")
          end
        end

        context "With two languages" do
          let(:subjects) do
            [
              modern_languages,
              find_or_create(:modern_languages_subject, :english_as_a_second_language_or_other_language),
              find_or_create(:modern_languages_subject, :spanish),
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
              find_or_create(:modern_languages_subject, :english_as_a_second_language_or_other_language),
              find_or_create(:modern_languages_subject, :french),
              find_or_create(:modern_languages_subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (English, French, Spanish)" do
            expect(generated_title).to eq("Modern Languages (English, French, Spanish)")
          end
        end
      end

      context "Modern Languages (Other) -> Should be ignored for the title" do
        context "With a single language" do
          let(:subjects) do
            [modern_languages, find_or_create(:modern_languages_subject, :modern_languages_other)]
          end

          it "Returns the title Modern Languages" do
            expect(generated_title).to eq("Modern Languages")
          end
        end

        context "With two languages" do
          let(:subjects) do
            [
              modern_languages,
              find_or_create(:modern_languages_subject, :modern_languages_other),
              find_or_create(:modern_languages_subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (Spanish)" do
            expect(generated_title).to eq("Modern Languages (Spanish)")
          end
        end

        context "With three languages" do
          let(:subjects) do
            [
              modern_languages,
              find_or_create(:modern_languages_subject, :modern_languages_other),
              find_or_create(:modern_languages_subject, :french),
              find_or_create(:modern_languages_subject, :spanish),
            ]
          end

          it "Returns the title Modern Languages (French and Spanish)" do
            expect(generated_title).to eq("Modern Languages (French and Spanish)")
          end
        end
      end
    end
  end
end
