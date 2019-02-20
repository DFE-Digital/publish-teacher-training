class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_fe:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_fe = is_fe
  end

  def to_a
    case
    when @is_pgde && @is_fe
      [:qtls, :pgde]
    when @is_pgde && !@is_fe
      [:qts, :pgde]
    when @is_fe
      [:qtls, :pgce]
    when @profpost_flag == "recommendation_for_qts"
      [:qts]
    else
      [:qts, :pgce]
    end
  end
end
