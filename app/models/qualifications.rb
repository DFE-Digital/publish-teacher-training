class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_fe:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_fe = is_fe
  end

  def to_a
    qts_or_not + uni_qualification_or_not
  end

private

  def qts_or_not
    @is_fe ? [] : [:qts]
  end

  def uni_qualification_or_not
    if @is_pgde
      [:pgde]
    elsif @profpost_flag == "recommendation_for_qts"
      []
    else
      [:pgce]
    end
  end
end
