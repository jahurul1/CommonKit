require 'sinatra'

get '/get' do
  "This is a test get."
end

post '/post' do
  "Post #{request.body.read}!"
end

put '/put' do
  "Put #{request.body.read}!"
end

delete '/delete' do
  "Deleted!"
end