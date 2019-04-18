describe ListLanguagesTaughtInModernLanguageCourse do
  describe '#call' do
    context "when the course isn't for modern languages" do
      let(:course_name) { 'Physical Education with French' }

      context 'with two language subjects' do
        let(:ucas_subject_names) do
          'French, German, Languages, Languages (European), Secondary'
        end

        subject { described_class.call(course_name, ucas_subject_names) }

        it { should eq([]) }
      end
    end

    context "when the course name contains MFL" do
      let(:course_name) { 'MFL - Spanish' }

      context 'with two language subjects' do
        let(:ucas_subject_names) do
          'French, German, Languages, Languages (European), Secondary'
        end

        subject { described_class.call(course_name, ucas_subject_names) }

        it { should eq(%w[french german]) }
      end
    end

    context 'when the course name contains "Modern Foreign Language"' do
      let(:course_name) { 'Modern Foreign Language (French)' }

      context 'with two language subjects' do
        let(:ucas_subject_names) do
          'French, German, Languages, Languages (European), Secondary'
        end

        subject { described_class.call(course_name, ucas_subject_names) }

        it { should eq(%w[french german]) }
      end
    end

    context 'when the course name contains "Modern Language"' do
      let(:course_name) { 'Modern Languages (Spanish with German)' }

      context 'with two language subjects' do
        let(:ucas_subject_names) do
          'French, German, Languages, Languages (European), Secondary'
        end

        subject { described_class.call(course_name, ucas_subject_names) }

        it { should eq(%w[french german]) }
      end
    end
  end
end
