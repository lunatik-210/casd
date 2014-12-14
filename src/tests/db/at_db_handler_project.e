note
	description: "Tests for routines in class DB_HANDLER_PROJECT"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-11$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_PROJECT

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_by_id_existent_project_test
			-- Test for routine find_by_id with existent project id.
		local
			db_handler : DB_HANDLER_PROJECT
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			json_result := db_handler.find_by_id (1)

				-- check attributes
			assert("Correct project_name ",json_result.item ("name").debug_output.is_equal("project1"))
			assert("Correct is_active ", json_result.item("status").debug_output.is_equal("Active"))
			assert("Correct description", json_result.item ("description").debug_output.is_equal("project1 descr"))
			assert("Correct max_points_per_sprint", json_result.item ("max_points_per_sprint").debug_output.is_equal("10"))
			assert("Correct number_of_sprints", json_result.item ("number_of_sprints").debug_output.is_equal("1"))
			assert("Correct user_id", json_result.item ("user_id").debug_output.is_equal("1"))
		end

	find_by_id_nonexistent_project_test
			-- Test for routine find_by_id with nonexistent project id.
		local
			db_handler : DB_HANDLER_PROJECT
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.find_by_id (100)
			assert("Project not found", json_result.is_empty)
		end

	add_project_test
			-- Test for routine add
		local
			project : PROJECT
			db_handler : DB_HANDLER_PROJECT
		do
			create project.make ("test_name", "test_status", "test_descrption", 100, 3)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(project)
				-- assert when the project was successfully added.
			assert ("Project successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the project added for test
			db_handler.db.rollback
		end

	update_project_test
			-- Test for routine update
		local
			project: PROJECT
			db_handler : DB_HANDLER_PROJECT
		do
			create project.make ("test_name", "test_status", "test_descrption", 100, 3)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(project)

			project.set_project_name ("new_name")
				-- update the project in database
			db_handler.update(db_handler.db_insert_statement.last_row_id.to_natural_32,project)
				-- assert when the project was successfully updated.
			assert("Project successfully updated", not db_handler.db_modify_statement.has_error)

				-- remove the user added for test
			db_handler.db.rollback
		end

	remove_project_test
		-- Test for routine remove
		local
			project : PROJECT
			db_handler : DB_HANDLER_PROJECT
			json_result : JSON_OBJECT
		do
			create project.make ("new_name", "new_status", "new_description", 100, 1)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (project)

			assert("Project added", not db_handler.db_insert_statement.has_error)

			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32)

			assert("Project removed ", not db_handler.db_insert_statement.has_error)

				-- remove the user added for test
			db_handler.db.rollback
		end



end
