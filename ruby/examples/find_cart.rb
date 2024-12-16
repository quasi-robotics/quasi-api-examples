require 'dotenv'
require 'async'

require_relative '../lib/quasi-api.rb'

Dotenv.load

Quasi::API.base_url = ENV['BASE_URL']

Async do
  u = Quasi::User.authenticate(ENV['USERNAME'], ENV['PASSWORD'])
  puts "Hello #{u.fullname}"

  c = Cart.find_by_sn(u, ENV['CART_SN'])
  puts 'Waypoints: '
  puts c.waypoints
  puts 'Routes: '
  puts c.routes
  u.logout
end
