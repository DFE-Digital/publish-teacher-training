module UCASSubjects
  describe UCASToDFESubjectMapping do
    context "when passed a static array of UCAS subjects" do
      subject { UCASToDFESubjectMapping.new(["maths", "maths (abridged)"], "Mathematics") }

      it { should be_applicable_to(%w[maths], :anything) }
      it { should be_applicable_to(["maths (abridged)", "something else"], :anything) }
      it { should_not be_applicable_to(%w[english], :anything) }

      its(:to_dfe_subject) { should eq(DFESubject.new("Mathematics")) }
    end

    context "when passed a lambda that matches on the course title" do
      subject {
        UCASToDFESubjectMapping.new(
          {
            ucas_subjects: ["english", "english literature"],
            course_title_matches: ->(course_title) { course_title =~ /english/ },
          },
          "English",
        )
      }

      it { should be_applicable_to(["english", "english literature", "something else"], "english language") }
      it { should_not be_applicable_to(["something else"], "english language") }
      it { should_not be_applicable_to(%w[english], "some other course title") }

      its(:to_dfe_subject) { should eq(DFESubject.new("English")) }
    end

    context "when passed a lambda that matches on the UCAS subjects list" do
      subject {
        UCASToDFESubjectMapping.new(
          {
            ucas_subjects_match: ->(ucas_subjects) { ucas_subjects.size == 2 },
          },
          "English",
        )
      }

      it { should be_applicable_to(%w[a b], :anything) }
      it { should_not be_applicable_to(%w[a], :anything) }
      it { should_not be_applicable_to(%[a b c], :anything) }

      its(:to_dfe_subject) { should eq(DFESubject.new("English")) }
    end
  end
end
