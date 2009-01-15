class Story
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :title, String
  property :updated_at, DateTime

  has_versions :ignore => [:updated_at]
end
