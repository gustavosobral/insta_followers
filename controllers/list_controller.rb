module Sinatra
  module InstaFollowers
    module Controllers
      module ListController
        def self.registered(app)
          app.get '/list' do
            follows = []
            followed_by = []
            @not_followers = []

            response = RestClient.get 'https://api.instagram.com/v1/users/self/follows',
              {:params => {:access_token => params[:access_token]}}  
            body = JSON.parse response.body, object_class: OpenStruct
            body.data.each { |user| follows << User.new(user) }

            response = RestClient.get 'https://api.instagram.com/v1/users/self/followed-by',
              {:params => {:access_token => params[:access_token]}}  
            body = JSON.parse response.body, object_class: OpenStruct
            body.data.each { |user| followed_by << User.new(user) }

            follows.each { |user| @not_followers << user if !followed_by.map(&:username).include? user.username }
            haml :list
          end
        end
      end
    end
  end
end
