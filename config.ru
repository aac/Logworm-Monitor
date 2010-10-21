require 'app'
require 'logworm_amqp'

use Logworm::Rack
run Sinatra::Application