note
	description: "Class that represents a user of the application."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	USER

create
	make

feature -- Initialization

	make(new_user_name, new_email, new_password : STRING)
			-- Create a new user with all the attributes.
		require
			valid_email: (new_email /= Void) and (new_email.count>0)
			valid_password: (new_password /= Void) and (new_password.count>0)
		do
			email := new_email
			if (new_user_name = Void) then
				username := ""
			else
				username := new_user_name
			end
			password := new_password
			is_active := true
		end

feature -- User data

	email : STRING

	username : STRING

	password : STRING

	is_active: BOOLEAN

feature -- Operations

	set_email (new_email : STRING)
			-- update the user email.
		require
			valid_email: (new_email /= Void) and (new_email.count>0)
		do
			email := new_email
		end

	set_user_name (new_user_name : STRING)
			-- update the user name
		do
			if (new_user_name = Void) then
				username := ""
			else
				username := new_user_name
			end
		end

	set_password (new_password : STRING)
			-- update the user password
		require
			valid_password: (new_password /= Void) and (new_password.count>0)
		do
			password := new_password
		end

end
