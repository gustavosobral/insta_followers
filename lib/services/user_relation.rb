class UserRelation
  attr_accessor :username, :profile_picture, :id, :full_name

  def initialize(object)
    @id = object.id
    @username = object.username
    @full_name = object.full_name
    @profile_picture = object.profile_picture    
  end
end
