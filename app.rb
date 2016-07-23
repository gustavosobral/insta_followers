ENV['RACK_ENV'] ||= 'development'

require 'sinatra'
require 'sinatra/cross_origin'
require 'data_mapper'
require 'json'
require 'dotenv'
require 'rest-client'
require 'sprockets'
require 'uglifier'
require 'sass'

# Enviroment configurations
configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :force_ssl, false
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :force_ssl, true
end

DataMapper::Property::String.length(255)

# Project modules
require_relative 'controllers/index_controller'
require_relative 'controllers/list_controller'

require_relative 'models/user'

class Relation
  attr_accessor :username, :profile_picture, :id, :full_name

  def initialize(object)
    @id = object.id
    @username = object.username
    @full_name = object.full_name
    @profile_picture = object.profile_picture    
  end
end

# Sinatra APP
class InstaFollowers < Sinatra::Base
  Dotenv.load
  enable :cross_origin

  set :root, File.dirname(__FILE__)
  set :haml, :format => :html5
  set :environment, Sprockets::Environment.new
  set :sessions => true
  set :session_secret, ENV['SECRET_KEY_BASE']

  environment.append_path 'assets/stylesheets'
  environment.append_path 'assets/javascripts'

  environment.js_compressor  = :uglify
  environment.css_compressor = :scss

  register do
    def auth (type)
      condition do
        redirect '/login' unless send("is_#{type}?")
      end
    end
  end

  register Sinatra::InstaFollowers::Controllers::IndexController
  register Sinatra::InstaFollowers::Controllers::ListController

  helpers do
    def is_user?
      @user != nil
    end
  end

  before do
    @user = User.get(session[:user_id])
  end

  get '/assets/*' do
    env['PATH_INFO'].sub!('/assets', '')
    settings.environment.call(env)
  end
end
