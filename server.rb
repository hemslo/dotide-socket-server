require 'eventmachine'
require 'em-http-request'
require 'json'

def required_attributes(params, keys)
  attrs = {}
  keys.each do |key|
    return false unless (params.has_key?(key) && !params[key].nil?)
    attrs[key] = params[key]
  end
  attrs
end

BASE_URL = 'http://127.0.0.1:9292'

module Server
  def post_init
    puts "-- someone connected to the echo server!"
  end

  def receive_data data
    send_data ">>>you sent: #{data}"
    close_connection if data =~ /quit/i
    puts "Recieved message: #{data}"
    begin
      json = JSON.parse(data)
    rescue
      res = { message: 'invalid json' }
      send_data res.to_json
      return
    end

    params = required_attributes(json, ['method', 'path','headers', 'body'])
    unless (params && %w(get post put delete).include?(params['method']))
      res = { message: 'invalid value "path"'}
      send_data res.to_json
      return
    end
    p params

    method = params['method'].to_sym
    url = BASE_URL + params['path']
    req = EM::HttpRequest.new(url)
    if req.respond_to? method
      http = req.send(method, { head: params['headers'], body: params['body'] })
    end

    http.callback {
      res = {
        status: http.response_header.status,
        headers: http.response_header,
        body: http.response
      }
      p res
      send_data res.to_json
    }

    http.errback {
      p http.error
      res = {
        message: http.error.to_s
      }
      send_data res.to_json
    }
  end

  def unbind
    puts "-- someone disconnected from the echo server!"
  end
end

# Note that this will block current thread.
EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8081, Server
}
