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
  c.navigate_to(ENV['WAYPOINT'])
  10.times do |i|
    sleep 1
    c.update_status
    puts c.navigation_feedback if c.navigation_feedback 
  end
  u.logout
end
