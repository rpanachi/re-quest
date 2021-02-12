class ReQuest

  REQUEST_HEADERS_MAP = {
    "HTTP_USER_AGENT" => "User-Agent",
    "HTTP_ACCEPT" => "Accept",
    "HTTP_AUTHORIZATION" => "Authorization",
    "HTTP_VERSION" => "Version",
    "CONTENT_TYPE" => "Content-Type",
  }.freeze

  def self.call(env)
    request  = Rack::Request.new(env)
    _request = HTTPI::Request.new

    debug("Params: #{request.params.inspect}")

    _url = request.params["url"]
    debug("URL: #{_url}")
    _request.url = _url

    _body = request.body.read
    debug("BODY: #{_body}")
    _request.body = _body

    request.each_header do |key, value|
      debug("request[#{key}]=#{value}")
    end

    REQUEST_HEADERS_MAP.each do |from, to|
      value = request.get_header(from)
      debug("_request.headers[#{to}] = request.headers[#{from}] = #{value}")
      _request.headers[to] = value
    end

    _method = request.request_method
    debug("METHOD: #{_method}")
    _response = HTTPI.request(_method, _request)

    response = Rack::Response.new
    body = StringIO.new(_response.body)
    debug("BODY: #{body.read}")
    body.rewind
    response.body    = body

    status = _response.code
    debug("STATUS: #{status}")
    response.status  = status

    _response.headers.each do |key, value|
      debug("response[#{key}]=#{value}")
      response.set_header(key, value)
    end

    response.finish
  end

  def self.debug(message)
    puts message
  end

end
