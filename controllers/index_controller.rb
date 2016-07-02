module Sinatra
  module InstaFollowers
    module Controllers
      module IndexController
        def self.registered(app)
          app.get '/' do
            haml :index
          end

          app.get '/get_token' do
            redirect '/' if params[:code].nil?

            response = RestClient.post 'https://api.instagram.com/oauth/access_token',
              "client_id" => ENV['CLIENT_ID'],
              "client_secret" => ENV['CLIENT_SECRET'],
              "grant_type" => "authorization_code",
              "redirect_uri"=> "#{ENV['URL']}/get_token",
              "code" => params[:code].to_s

            body = JSON.parse response.body
            redirect "/list?access_token=#{body['access_token']}"
          end
        end
      end
    end
  end
end
