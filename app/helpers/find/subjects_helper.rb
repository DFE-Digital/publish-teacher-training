module Find::SubjectsHelper
  def subject_display_name(subject)
    subject.name == "Modern languages (other)" ? "Other modern languages" : subject.name
  end
end
