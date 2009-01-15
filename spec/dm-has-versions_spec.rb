require File.dirname(__FILE__) + '/spec_helper'

describe "dm-has-versions" do
  describe "a story which should have versions" do
    before do
      Story.all.destroy!
      @story = Story.new(:title => 'test-1')
      @story.save
    end

    it "should tested on 1 story" do
      Story.count.should == 1
      @story.should_not be_new_record
      @story.title.should == 'test-1'
    end

    it "should have Version class" do
      Story.const_get(:Version).should_not be_nil
      Story::Version.should be_respond_to(:properties)
    end

    it "should have versions" do
      @story.should be_respond_to(:versions)
      @story.versions.should be_kind_of(DataMapper::Collection)
    end
  end
end
