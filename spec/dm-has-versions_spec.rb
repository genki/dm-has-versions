require File.dirname(__FILE__) + '/spec_helper'

describe "dm-has-versions" do
  describe "a story which should have versions" do
    before do
      Story.all.destroy!
      Story.auto_migrate!
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
      @story.versions.should be_empty
    end

    it "should generate versions" do
      @story.versions.should be_empty
      @story.update_attributes :title => 'test-2'
      @story.versions.should be_present
      @story.versions.size.should == 1
      @story.update_attributes :title => 'test-3'
      @story.versions.size.should == 2
    end

    it "should not generate versions on update of ignoring properties" do
      @story.versions.should be_empty
      @story.update_attributes :updated_at => Time.now
      @story.versions.should be_empty
    end

    it "should not generate versions if the story was not modified" do
      @story.versions.should be_empty
      @story.save
      @story.versions.should be_empty
    end

    describe "destory and revert of versions" do
      before do
        @story.update_attributes :title => 'test-2'
        @story.update_attributes :title => 'test-3'
        @story.update_attributes :title => 'test-4'
      end

      it "should be tested on 3 versions" do
        @story.versions.count.should == 3
        @story.version.should == 3
      end

      it "should emptyfy by calling destroy!" do
        @story.versions.destroy!
        @story.versions.should be_empty
      end

      it "should revert stories" do
        @story.title.should == "test-4"
        @story.revert_to(2).should be_true
        @story.title.should == "test-3"
        @story.versions.should be_present
        @story.revert_to(0).should be_true
        @story.version.should == 0
        @story.title.should == "test-1"
      end

      it "should be set version" do
        @story.title.should == "test-4"
        @story.version.should == 3
        @story.dirty_attributes[Story.title].should be_nil
        @story.version = 1
        @story.version.should == 1
        @story.title.should == "test-2"
        @story.dirty_attributes[Story.title].should_not be_nil
      end

      it "should revert to current version" do
        @story.version = 1
        @story.should_not be_latest
        @story.save
        @story.should be_latest
        @story.title.should == "test-2"
        @story.dirty_attributes[Story.title].should be_nil
      end

      it "should destroy all versions if the story was dstroyed" do
        @story.versions.should_not be_empty
        @story.destroy
        Story::Version.all(:story_id => @story.id).should be_empty
      end

      it "should keep child_models while version control" do
        @story.comments.create :body => "Hey, maiha!"
        @story.comments.count.should == 1
        story = Story.get(@story.id)
        story.version.should == 3
        story.version = 1
        story.title.should == 'test-2'
        story.comments.should_not be_empty
        story.comments.last.body.should == "Hey, maiha!"
      end
    end
  end
end
