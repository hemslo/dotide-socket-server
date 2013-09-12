require 'eventmachine'
require 'json'

class Client < EventMachine::Connection
  def post_init
    req = {
      method: 'get',
      path: '/v1/products/51de7a72c26bacb440000001',
      headers: { ApiKey: '73fb9b13cb05b076ce3d20d966f608b5b0c2d2a4' },
      body: ''
    }
    send_data JSON.generate(req)
  end

  def receive_data(data)
    p data
  end
end

EventMachine.run {
  EventMachine.connect '127.0.0.1', 8081, Client
}
