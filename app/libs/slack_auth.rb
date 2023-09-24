module App
  class SlackAuth
    attr_accessor :slack_secret, :version, :paths

    def initialize(app, slack_secret, path: nil, version: 'v0')
      @app = app
      @slack_secret = slack_secret
      @version = version
      @paths = path
    end

    def call(env)
      request = Rack::Request.new(env)
      return @app.call(env) unless path_match?(request)

      return unauthorized unless authorized?(request)

      @app.call(env)
    end

    private

    def authorized?(request)
      timestamp = request.env['HTTP_X_SLACK_REQUEST_TIMESTAMP']

      # check that the timestamp is recent (~5 mins) to prevent replay attacks
      return false if Time.at(timestamp.to_i) < Time.now - (60 * 5)

      # generate hash
      request_body = request.body.read
      request.body.rewind
      computed_signature = generate_hash(timestamp, request_body)

      # compare generated hash with slack signature
      slack_signature = request.env['HTTP_X_SLACK_SIGNATURE']
      computed_signature == slack_signature
    end

    def generate_hash(timestamp, request_body)
      sig_basestring = "#{version}:#{timestamp}:#{request_body}"
      digest   = OpenSSL::Digest.new('SHA256')
      hex_hash = OpenSSL::HMAC.hexdigest(digest, slack_secret, sig_basestring)

      "#{version}=#{hex_hash}"
    end

    def path_match?(request)
      if paths
        paths.any? { |path| request.env['PATH_INFO'] == path }
      else
        true
      end
    end

    def unauthorized
      [401,
       { 'Content_Type' => 'text/plain',
         'Content' => '0' },
       []]
    end
  end
end
