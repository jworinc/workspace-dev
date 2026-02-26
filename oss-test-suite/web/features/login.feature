Feature: Mission Control Login
  As a user
  I want to log in to Mission Control
  So that I can see my agent dashboard

  Scenario: Successful login with valid credentials
    Given I am on "http://localhost:3000/login"
    When I enter "admin" in the username field
    And I enter "password123" in the password field
    And I click "Sign In"
    Then I should be redirected to "/dashboard"
    And I should see "Welcome, Admin"
