module Sinatra
  module InstaFollowers
    module Controllers
      module ListController
        def self.registered(app)
          app.get '/list', :auth => :user do
            follows = []
            followed_by = []
            @not_followers = []

            response = RestClient.get 'https://api.instagram.com/v1/users/self/follows',
              {:params => {:access_token => @user.access_token}}
            body = JSON.parse response.body, object_class: OpenStruct
            body.data.each { |user| follows << Relation.new(user) }

            response = RestClient.get 'https://api.instagram.com/v1/users/self/followed-by',
              {:params => {:access_token => @user.access_token}}
            body = JSON.parse response.body, object_class: OpenStruct
            body.data.each { |user| followed_by << Relation.new(user) }

            follows.each { |user| @not_followers << user if !followed_by.map(&:username).include? user.username }
            haml :list
          end

          app.post '/unfollow', :auth => :user do
            ids = params.keys
            ids.each do |id| 
              RestClient.post "https://api.instagram.com/v1/users/#{id}/relationship", :access_token => @user.access_token, :action => 'unfollow'
            end
            redirect '/list'
          end
        end
      end
    end
  end
end
