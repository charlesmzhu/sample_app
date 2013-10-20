require 'spec_helper'

describe User do
  before {@user = User.new(name: "Example User", email: "user@example.com", password: "foobar", password_confirmation: "foobar")}

  subject { @user }

  it {should respond_to(:name, :email, :password_digest, :password, :password_confirmation, :authenticate)}

  it {should be_valid}

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
      specify {expect(user_for_invalid_password.to be_false)} #duble checks that authenticate also returns false
    end
  end
end