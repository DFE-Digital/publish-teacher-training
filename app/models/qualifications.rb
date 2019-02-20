class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_fe:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_fe = is_fe
  end

  def to_a
    case
    when @is_pgde && @is_fe
      [:pgde] # 'PGDE'
    when @is_pgde && !@is_fe
      [:qts, :pgde] # 'PGDE with QTS'
    when @is_fe
      [:pgce] # 'PGCE'
    when @profpost_flag == "recommendation_for_qts"
      [:qts] # 'QTS'
    else
      [:qts, :pgce] # 'PGCE with QTS'
    end
  end
end
