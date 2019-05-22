class DFESubject
  def initialize(subject_name)
    @subject_name = subject_name
  end

  def to_s
    @subject_name
  end

  def ==(other)
    to_s == other.to_s
  end
end
