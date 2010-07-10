require 'sinatra'

get '/get' do
  if params["name"]
    "Hello #{params["name"]}!"
  else
    "This is a test get."
  end
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

get '/slow' do
  sleep 2
  "Should have timed out!"
end