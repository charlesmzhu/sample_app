require 'spec_helper'

describe User do
  before {@user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")}

  subject { @user }

  it {should respond_to(:name, :email, :password_digest, :password, :password_confirmation, :authenticate, 
    :password_confirmation, :remember_token, :authenticate, :admin, :microposts, :feed)}

  it {should be_valid} #positive test, after this is all the negative tests

  describe "remember token" do
    before {@user.save}
    its(:remember_token) {should_not be_blank}
  end

  describe "when name is not present" do
  	before {@user.name = " "}
  	it {should_not be_valid}
  end

  describe "when name is too long" do
  	before {@user.name = "a"*50}
  	it {should_not be_valid}
  end

  describe "when email is not present" do
  	before {@user.email = " "}
  	it {should_not be_valid}
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      
      addresses.each do |invalid_address|
        @user.email = invalid_address
        expect(@user).not_to be_valid
      end
    end
  end

  describe "when email format is valid" do
  	it "should be invalid" do
  		addresses = %w[users@foo.com A_USEe@gkoe23lld.com a+b@bar.cn]
  		addresses.each do |valid_address|
  			@user.email = valid_address
  			expect(@user).to be_valid
  		end
  	end
  end

  describe "when email is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it {should_not be_valid}
  end

  describe "when password is not present" do
    before do
      @user.password = " "
      @user.password_confirmation = " "
    end
    it {should_not be_valid}

  end

  describe "when password does not match" do
    before {@user.password_confirmation = "mismatch"}
    it {should_not be_valid}
  end

  describe "return value of authenticate method" do
    before {@user.save}
    let(:found_user) {User.find_by(email: @user.email)}

    describe "with valid password" do
      it {should eq found_user.authenticate(@user.password)}
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) {found_user.authenticate("invalid")}

      it {should_not eq user_for_invalid_password} #tests that authenticate does not return the same thing as the user
      specify {expect(user_for_invalid_password).to be_false} #duble checks that authenticate also returns false
    end
  end

  it { should respond_to(:authenticate)}
  it { should respond_to(:admin)}

  it { should be_valid }
  it { should_not be_admin}

  describe "with admin attribute set to 'true'" do
    before do
      @user.save!
      @user.toggle!(:admin)
    end

    it {should be_admin}    
  end

  describe "micropost associations" do
    before {@user.save}
    let!(:older_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      FactoryGirl.create(:micropost, user: @user, created_at: 1.hour.ago)
    end

    it "should have the microposts in the right order" do
      expect(@user.microposts.to_a).to eq [newer_micropost, older_micropost]
    end

    it "should destroy associated microposts" do
      microposts = @user.microposts.to_a
      @user.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end

    describe "status" do
      let(:unfollowed_post) do
        FactoryGirl.create(:micropost, user: FactoryGirl.create(:user))
      end

      its(:feed){should include(newer_micropost)}
      its(:feed){should include(older_micropost)}
      its(:feed){should_not include(unfollowed_post)}
    end
  end
end