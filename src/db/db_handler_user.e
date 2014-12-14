note
	description: "This class manages the database operations that concerns users."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-08$"
	revision: "$0.01$"

class
	DB_HANDLER_USER

inherit
	CASD_DB

create
	make

feature -- Data access

	find_all : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a user
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Users;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 4, Result))
		end

	find_by_id (user_id : NATURAL) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents a user that corresponds to the given id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Users WHERE id="+ user_id.out +";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 5, Result))
		ensure
			correct_id: Result.item ("id").debug_output.is_equal(user_id.out)
		end

	find_by_project_id (project_id : NATURAL): JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a user that
			-- is collaborator of the project.
		do
			create Result.make_array
			create db_query_statement.make ("SELECT u.id,u.user_name,u.email FROM Collaborators c NATURAL JOIN Users u "+
											"WHERE c.user_id=u.id AND c.project_id="+ project_id.out + " AND u.is_active=1;", db)
			db_query_statement.execute (agent rows_to_json_array(?, 3, Result))
		end

	add (user : USER)
			-- adds a new user
		require
			valid_user: (user/=Void)
		do
			create db_insert_statement.make ("INSERT INTO Users(user_name,is_active,email,password) "+
											"VALUES ('" + user.username + "','"+ user.is_active.to_integer.out +"',"+
											"'"+ user.email +"','"+ user.password +"');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new user")
			end
		end

	update (user_id : NATURAL;user: USER)
			-- updates a user
		require
			valid_user: (user/=Void)
		do
			create db_modify_statement.make ("UPDATE Users SET user_name = '"+ user.username +"',"+
															  "email = '"+ user.email +"',"+
															  "password = '"+ user.password +"'"+
															  "WHERE id="+ user_id.out +";" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating a user")
			end
		end

	remove (user_id: NATURAL)
			-- removes the user with the given id
		do
			create db_modify_statement.make ("UPDATE Users SET is_active = 0 WHERE id=" + user_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a User")
			end
		end

	has_user (a_email: STRING): TUPLE[has_user: BOOLEAN; user_id: STRING; is_active: STRING; email: STRING; hashed_pass: STRING]
			-- checks if a user with given email exists
			-- if yes, the result tuple value "has_user" will be true and "user_id"."email" and "hashed_pass" will be set
			-- otherwise, "has_user" will be false and "user_id", "email" and "hashed_pass" will not be set
		require
			valid_email: (a_email/=Void) and (a_email.count>0)
		local
			json_result : JSON_OBJECT
		do
				-- create a result object
			create Result
			create json_result.make

			create db_query_statement.make ("SELECT * FROM Users WHERE email='"+ a_email +"';", db)
			db_query_statement.execute (agent row_to_json_object(?, 5, json_result))

			if json_result.is_empty then
					-- there are no rows in the result of the query, thus no user with that password exits
				Result.has_user := False
			else
				Result.has_user := True
				Result.user_id := json_result.item ("id").debug_output.out
				Result.is_active := json_result.item ("is_active").debug_output.out
				Result.email := json_result.item ("email").debug_output.out
				Result.hashed_pass := json_result.item ("password").debug_output.out
			end
		ensure
			correct_result: (not Result.has_user) or (Result.has_user and Result.email.is_equal(a_email))
		end

end
