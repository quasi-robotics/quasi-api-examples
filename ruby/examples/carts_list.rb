require 'dotenv'
require 'async'

require_relative '../lib/quasi-api.rb'

Dotenv.load

Quasi::API.base_url = ENV['BASE_URL']

Async do
  u = Quasi::User.authenticate(ENV['USERNAME'], ENV['PASSWORD'])
  puts "Hello #{u.fullname}"
  puts Cart.list(u)
  u.logout
end

