class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_further_education:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_further_education = is_further_education
  end

  def to_a
    qts_if_any + qualification_awarded_by_uni_if_any
  end

private

  def qts_if_any
    @is_further_education ? [] : [:qts]
  end

  def qualification_awarded_by_uni_if_any
    if @is_pgde
      [:pgde]
    elsif @profpost_flag == "recommendation_for_qts"
      []
    else
      [:pgce]
    end
  end
end
