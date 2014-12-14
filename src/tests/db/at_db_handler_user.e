note
	description: "[
		Tests for routines of class DB_HANDLER_USER
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-11$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_USER

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_all_test
			-- Test for routine find_all
		local
			db_handler : DB_HANDLER_USER
			json_array_result : JSON_ARRAY
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			json_array_result := db_handler.find_all

			assert("Users obtained.", json_array_result.count>0 )
		end

	find_by_id_existent_user_test
			-- Test for routine find_by_id with existent user id.
		local
			db_handler : DB_HANDLER_USER
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd.db")

			json_result := db_handler.find_by_id (1)

				-- correct attributes
			assert("Correct user_name ",json_result.item ("user_name").debug_output.is_equal("name"))
			assert("Correct email ", json_result.item ("email").debug_output.is_equal("name1@mail.com"))
			assert("Correct is_active ", json_result.item("is_active").debug_output.is_equal("1"))
		end

	find_by_id_nonexistent_user_test
			-- Test for routine find_by_id with nonexistent user id.
		local
			db_handler : DB_HANDLER_USER
			json_result : JSON_OBJECT
			ok, second_time : BOOLEAN
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd.db")
			if not second_time then
				ok := true
				json_result := db_handler.find_by_id (100)
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

	find_by_project_id_project_with_collaborators_test
			-- Test for routine find_by_project_id with a project that have collaborators.
		local
			db_handler : DB_HANDLER_USER
			json_array_result : JSON_ARRAY
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_array_result := db_handler.find_by_project_id (1)
			assert("Users obtained", json_array_result.count>0)
		end

	find_by_project_id_project_without_collaborators_test
		-- Test for routine find_by_project_id with a project without collaborators.
		local
			db_handler : DB_HANDLER_USER
			json_array_result : JSON_ARRAY
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_array_result := db_handler.find_by_project_id (100)
			assert("There are no users ", json_array_result.count=0)
		end

	add_user_test
			-- Test for routine add
		local
			user : USER
			db_handler : DB_HANDLER_USER
		do
			create user.make ("email@email.com", "Name", "pass")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(user)
				-- assert when the user was successfully added.
			assert ("User successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the user added for test
			db_handler.db.rollback
		end

	update_user_test
			-- Test for routine update
		local
			user : USER
			db_handler : DB_HANDLER_USER
		do
			create user.make("email@email.com","Name","pass")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(user)

			user.set_user_name("NewName")
				-- update the user in database
			db_handler.update(db_handler.db_insert_statement.last_row_id.to_natural_32,user)
				-- assert when the user was successfully updated.
			assert("User successfully updated", not db_handler.db_modify_statement.has_error)

				-- remove the user added for test
			db_handler.db.rollback
		end

	remove_user_test
		-- Test for routine remove
		local
			user : USER
			db_handler : DB_HANDLER_USER
			json_result : JSON_OBJECT
		do
			create user.make("email@email.com","Name","pass")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (user)
			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32)

				-- assert when the user was successfully removed (The attribute is_active must be false).
			json_result := db_handler.find_by_id (db_handler.db_insert_statement.last_row_id.to_natural_32)
			assert("User inactive ", json_result.item ("is_active").debug_output.is_equal("0") )

				-- remove the user added for test
			db_handler.db.rollback
		end

	has_user_with_correct_user_data_test
		-- Test for routine has_user
		local
			db_handler : DB_HANDLER_USER
			l_user_data: TUPLE [has_user: BOOLEAN; user_id: STRING; email: STRING; hashed_pass: STRING]
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			l_user_data := db_handler.has_user ("name1@mail.com")
			assert("User found", l_user_data.has_user)
			assert("Correct user_id", l_user_data.user_id.is_equal ("1"))
		end

	has_user_with_incorrect_user_data_test
		-- Test for routine has_user
		local
			db_handler : DB_HANDLER_USER
			l_user_data: TUPLE [has_user: BOOLEAN; user_id: STRING; email: STRING; hashed_pass: STRING]
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			l_user_data := db_handler.has_user ("no mail")
			assert("User not found", not l_user_data.has_user)
		end

end


