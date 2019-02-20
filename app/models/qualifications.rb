class Qualifications
  def initialize(profpost_flag:, is_pgde:, is_fe:)
    @profpost_flag = profpost_flag
    @is_pgde = is_pgde
    @is_fe = is_fe
  end

  def to_a
    result = []
    result << :qts unless @is_fe
    result += if @is_pgde
                [:pgde] # 'PGDE'
              elsif @profpost_flag == "recommendation_for_qts"
                []
              else
                [:pgce]
              end
    result
  end
end
