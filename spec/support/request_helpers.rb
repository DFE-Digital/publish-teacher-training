module RequestHelpers
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
