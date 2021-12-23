require "rails_helper"

module Support
  describe EditCourseForm do
    let(:course) { create(:course, course_code: "T92", name: "Universitry of Oxfords", start_date: Date.new(2022, 9, 1)) }

    subject { described_class.new(course) }

    it "can initalise an instance of itself" do
      expect(subject).to be_instance_of(EditCourseForm)
    end

    describe "#save" do
      context "form is assigned valid details" do
        it "returns true" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2022")
          expect(subject.save).to eq(true)
        end
      end

      context "form is assigned invalid date value" do
        it "returns true" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "222", month: "9", year: "2022")
          expect(subject.save).to eq(false)
        end
      end

      context "form is assigned blank values" do
        it "returns false" do
          subject.assign_attributes(course_code: "", name: "", day: "", month: "", year: "")
          expect(subject.save).to eq(false)
        end
      end

      context "form is assigned invalid date year" do
        it "returns false" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2027")
          expect(subject.save).to eq(false)
        end
      end
    end

    describe "#valid?" do
      context "form is assigned date with valid format" do
        it "can return true if valid start date" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2022")
          subject.save
          subject.valid?

          expect(subject.valid?).to eq(true)
          expect(subject.errors.messages.count).to eq(0)
          expect(subject.errors.messages[:start_date]).not_to include("Start date format is invalid")
        end
      end

      context "form is assigned date with invalid format" do
        it "can return date format error only" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "111", month: "90", year: "2022")
          subject.save

          expect(subject.valid?).to eq(false)
          expect(subject.errors.messages.count).to eq(1)
          expect(subject.errors.messages[:start_date]).to include("Start date format is invalid")
        end
      end

      context "form is assigned date args with blank values" do
        it "can promote and return errors" do
          subject.assign_attributes(course_code: "", name: "", day: "", month: "", year: "")
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
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2027")
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
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2022")
          expect(subject.start_date).to eq(Date.new(2022, 9, 2))
        end
      end

      context "form is assigned invalid date year" do
        it "returns a date object" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "2", month: "9", year: "2027")
          expect(subject.start_date).to eq(Date.new(2027, 9, 2))
        end
      end

      context "form is assigned invalid date args" do
        it "returns struct object" do
          subject.assign_attributes(course_code: "T92", name: "Universitry of Oxfords", day: "222", month: "90", year: "2022")
          output = subject.start_date
          expect(output).not_to be_instance_of(Date)
          expect(output.day).to eq("222")
          expect(output.month).to eq("90")
          expect(output.year).to eq("2022")
        end
      end

      context "form is assigned blank values" do
        it "returns struct object" do
          subject.assign_attributes(course_code: "", name: "", day: "", month: "", year: "")
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
