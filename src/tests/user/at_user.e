note
	description: "[
		Tests for routines of class User
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	AT_USER

inherit
	EQA_TEST_SET

feature -- Test routines

	make_test
			-- Test that create a user with valid attributes values.
		local
			user : USER
		do
			create user.make("John","john@mail.com","secret")
			assert ("Email ok", user.email.is_equal("john@mail.com"))
			assert ("Username ok", user.username.is_equal("John"))
			assert ("Password ok", user.password.is_equal("secret"))
			assert ("Status ok", user.is_active)
		end

	set_email_test
			-- Test for routine set_email
		local
			user : USER
		do
			create user.make ("John", "john@mail.com", "secret")
			user.set_email ("john.new@mail.com")
			assert("Email ok", user.email.is_equal ("john.new@mail.com"))
		end

	set_user_name_test
			-- Test for routine set_user_name
		local
			user : USER
		do
			create user.make ("John", "john@mail.com", "secret")
			user.set_user_name ("John7")
			assert("Username ok", user.username.is_equal ("John7"))
		end

	set_password_test
			-- Test for routine set_password
		local
			user : USER
		do
			create user.make ("John", "john@mail.com", "secret")
			user.set_password ("newsecret")
			assert("Password ok", user.password.is_equal ("newsecret"))
		end
end



