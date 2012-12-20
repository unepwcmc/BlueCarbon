### UTILITY METHODS ###

def create_visitor
  @visitor ||= { name: "Testy McUserton", email: "example@example.com",
    password: "please", password_confirmation: "please" }
end

def delete_user
  @user ||= User.first conditions: { email: @visitor[:email] }
  @user.destroy unless @user.nil?
end

### GIVEN ###

Given /^I do not exist as a user$/ do
  create_visitor
  delete_user
end

### WHEN ###

When /^I sign in with valid credentials$/ do
  pending # express the regexp above with the code you wish you had
end

### THEN ###

Then /^I see an invalid login message$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be signed out$/ do
  pending # express the regexp above with the code you wish you had
end
