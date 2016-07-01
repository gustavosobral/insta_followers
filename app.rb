require 'json'
require 'dotenv'
require 'byebug'
require 'sinatra'
require 'sinatra/cross_origin'
require 'rest-client'

configure do
  Dotenv.load
  enable :cross_origin
  set :haml, :format => :html5
end

class User
  attr_accessor :username, :profile_picture, :id, :full_name

  def initialize(object)
    @username = object.username
    @profile_picture = object.profile_picture
    @id = object.id
    @full_name = object.full_name
  end
end

get '/' do
  haml :index
end

get '/get_token' do
  redirect '/' if params[:code].nil?

  response = RestClient.post 'https://api.instagram.com/oauth/access_token',
    "client_id" => ENV['CLIENT_ID'],
    "client_secret" => ENV['CLIENT_SECRET'],
    "grant_type" => "authorization_code",
    "redirect_uri"=> "http://localhost:3000/get_token",
    "code" => params[:code].to_s

  body = JSON.parse response.body
  redirect "/list?access_token=#{body['access_token']}"
end

get '/list' do
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
