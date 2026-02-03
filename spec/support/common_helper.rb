module CommonHelper
  def parsed_body
    @parsed_body ||= begin
      body = respond_to?(:response_body) ? response_body : response.body
      JSON.parse(body)
    end
  rescue JSON::ParserError
    puts "PARSE ERROR!"
    puts body.inspect
    nil
  end
end
