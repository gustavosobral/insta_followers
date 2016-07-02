class User
  include DataMapper::Resource
  property :id, Serial
  property :access_token, String
  property :username, String
  property :full_name, String
  property :profile_picture, String 
  property :bio, Text
  property :website, String
end

DataMapper.finalize

User.auto_upgrade!
