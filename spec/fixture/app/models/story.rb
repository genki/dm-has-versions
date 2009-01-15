class Story
  include DataMapper::Resource

  property :id, Integer, :serial => true
  property :title, String
  property :updated_at, DateTime

  has n, :comments
  has_versions :ignore => [:updated_at]
end
