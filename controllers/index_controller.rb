module Sinatra
  module InstaFollowers
    module Controllers
      module IndexController
        def self.registered(app)
          app.get '/' do
            haml :index
          end

          app.get '/login' do
            redirect '/' if params[:code].nil?

            response = RestClient.post 'https://api.instagram.com/oauth/access_token',
              'client_id' => ENV['CLIENT_ID'],
              'client_secret' => ENV['CLIENT_SECRET'],
              'grant_type' => 'authorization_code',
              'redirect_uri' => "#{ENV['URL']}/login",
              'code' => params[:code].to_s

            body = JSON.parse response.body

            user = User.first_or_create({ :id => body['user']['id']})
            user.attributes = body['user']
            user.access_token = body['access_token']
            user.save!
            session[:user_id] = user.id
            
            redirect '/list'
          end

          app.get '/logout' do
            session[:user_id] = nil
            redirect '/'
          end
        end
      end
    end
  end
end
