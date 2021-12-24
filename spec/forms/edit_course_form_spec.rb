require "rails_helper"

module Support
  describe EditCourseForm do
    let(:course) { create(:course, course_code: "T92", name: "Universitry of Oxfords", start_date: Date.new(2022, 9, 1)) }
    let(:valid_attributes) { { course_code: "T92", name: "Universitry of Oxfords", start_date_day: "2", start_date_month: "9", start_date_year: "2022" } }
    let(:attributes_with_invalid_date_format) { { course_code: "T92", name: "Universitry of Oxfords", start_date_day: "222", start_date_month: "90", start_date_year: "2022" } }
    let(:attributes_with_invalid_date_year) { { course_code: "T92", name: "Universitry of Oxfords", start_date_day: "2", start_date_month: "9", start_date_year: "2027" } }
    let(:blank_attributes) { { course_code: "", name: "", start_date_day: "", start_date_month: "", start_date_year: "" } }

    subject { described_class.new(course) }

    it "can initalise an instance of itself" do
      expect(subject).to be_instance_of(EditCourseForm)
    end

    describe "#save" do
      context "form is assigned valid details" do
        it "returns true" do
          subject.assign_attributes(valid_attributes)
          expect(subject.save).to eq(true)
        end
      end

      context "form is assigned invalid date value" do
        it "returns true" do
          subject.assign_attributes(attributes_with_invalid_date_format)
          expect(subject.save).to eq(false)
        end
      end

      context "form is assigned blank values" do
        it "returns false" do
          subject.assign_attributes(blank_attributes)
          expect(subject.save).to eq(false)
        end
      end

      context "form is assigned invalid date start_date_year" do
        it "returns false" do
          subject.assign_attributes(attributes_with_invalid_date_year)
          expect(subject.save).to eq(false)
        end
      end
    end

    describe "#valid?" do
      context "form is assigned date with valid format" do
        it "can return true if valid start date" do
          subject.assign_attributes(valid_attributes)
          subject.save
          subject.valid?

          expect(subject.valid?).to eq(true)
          expect(subject.errors.messages.count).to eq(0)
          expect(subject.errors.messages[:start_date]).not_to include("Start date format is invalid")
        end
      end

      context "form is assigned date with invalid format" do
        it "can return date format error only" do
          subject.assign_attributes(attributes_with_invalid_date_format)
          subject.save

          expect(subject.valid?).to eq(false)
          expect(subject.errors.messages.count).to eq(1)
          expect(subject.errors.messages[:start_date]).to include("Start date format is invalid")
        end
      end

      context "form is assigned date args with blank values" do
        it "can promote and return errors" do
          subject.assign_attributes(blank_attributes)
          subject.save
          subject.valid?

          expect(subject.errors.messages.count).to eq(3)
          expect(subject.errors.messages[:course_code]).to include("Course code cannot be blank")
          expect(subject.errors.messages[:name]).to include("Course title cannot be blank")
          expect(subject.errors.messages[:start_date]).to include("Start date cannot have blank values")
        end
      end

      context "form is assigned date args with date outside current cycle" do
        it "can promote and return errors" do
          subject.assign_attributes(attributes_with_invalid_date_year)
          subject.save
          subject.valid?

          expect(subject.errors.messages.count).to eq(1)
          expect(subject.errors.messages[:start_date]).to include("September 2027 is not in the 2022 cycle")
        end
      end
    end

    describe "#start_date" do
      context "form is assigned valid date args" do
        it "returns a date object" do
          subject.assign_attributes(valid_attributes)
          expect(subject.start_date).to eq(Date.new(2022, 9, 2))
        end
      end

      context "form is assigned invalid date start_date_year" do
        it "returns a date object" do
          subject.assign_attributes(attributes_with_invalid_date_year)
          expect(subject.start_date).to eq(Date.new(2027, 9, 2))
        end
      end

      context "form is assigned invalid date args" do
        it "returns struct object" do
          subject.assign_attributes(attributes_with_invalid_date_format)
          output = subject.start_date
          expect(output).not_to be_instance_of(Date)
          expect(output.day).to eq("222")
          expect(output.month).to eq("90")
          expect(output.year).to eq("2022")
        end
      end

      context "form is assigned blank values" do
        it "returns struct object" do
          subject.assign_attributes(blank_attributes)
          output = subject.start_date
          expect(output).not_to be_instance_of(Date)
          expect(output.day).to eq("")
          expect(output.month).to eq("")
          expect(output.year).to eq("")
        end
      end
    end
  end
end
