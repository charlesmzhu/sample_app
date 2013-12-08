require 'spec_helper'

describe Relationship do
  let(:follower){FactoryGirl.create(:user)}
  let(:followed){FactoryGirl.create(:user)}

  let(:relationship){follower.relationships.build(followed_id: followed.id)}

  subject {relationship}

  it {should be_valid}

  describe "when follower does not exist" do
  	before {relationship.follower_id=nil}
  	it{should_not be_valid}
  end

  describe "when followed does not exist" do
  	before {relationship.followed_id=nil}
  	it{should_not be_valid}
  end
end
