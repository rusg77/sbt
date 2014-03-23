require 'sinatra'
require 'haml'


get '/' do
  haml :index
end

get '/result' do
  'Results'
end