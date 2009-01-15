class Comment
  include DataMapper::Resource

  property :body, Text

  belongs_to :story
end
