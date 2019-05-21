module Subjects
  describe CourseLevel do
    subject { CourseLevel.new(ucas_subjects) }

    context "for a primary course" do
      let(:ucas_subjects) { %w[Primary Mathematics] }
      its(:level) { should eq(:primary) }
    end

    context "for a secondary course" do
      let(:ucas_subjects) { %w[Secondary English] }
      its(:level) { should eq(:secondary) }
    end

    context "for a further education course" do
      let(:ucas_subjects) { ["Post-compulsory", "Humanities"] }
      its(:level) { should eq(:further_education) }
    end

    context "for a course with an unmapped subject" do
      let(:ucas_subjects) { ["Law", "Home economics"] }

      it "raises an error when fetching the level" do
        expect { subject.level }.to raise_error(RuntimeError, "found unsupported subject name(s): law, home economics")
      end
    end
  end
end
