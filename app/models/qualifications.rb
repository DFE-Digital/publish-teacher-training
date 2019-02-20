class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_fe:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_fe = is_fe
  end

  def to_a
    if @is_pgde && @is_fe
      [:pgde] # 'PGDE'
    elsif @is_pgde && !@is_fe
      %i[qts pgde] # 'PGDE with QTS'
    elsif @is_fe
      [:pgce] # 'PGCE'
    elsif @profpost_flag == "recommendation_for_qts"
      [:qts] # 'QTS'
    else
      %i[qts pgce] # 'PGCE with QTS'
    end
  end
end
