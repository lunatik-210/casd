note
	description: "Tests for routines in class DB_HANDLER_PROJECT"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-26$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_SPRINT

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_by_id_existent_sprint_test
			-- Test for routine find_by_id_and_project_id with existent sprint.
		local
			db_handler : DB_HANDLER_SPRINT
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			json_result := db_handler.find_by_id_and_project_id (0, 1)

				-- check attributes
			assert("Correct id",json_result.item ("id").debug_output.is_equal("0"))
			assert("Correct status", json_result.item("status").debug_output.is_equal("Backlog"))
			assert("Correct duration", json_result.item ("duration").debug_output.is_equal("0"))
			assert("Correct project_id", json_result.item ("project_id").debug_output.is_equal("1"))
		end

	find_by_id_nonexistent_project_test
			-- Test for routine find_by_id_and_project_id with nonexistent sprint.
		local
			db_handler : DB_HANDLER_SPRINT
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.find_by_id_and_project_id (20, 20)
			assert("Sprint not found", json_result.is_empty)
		end

	add_sprint_test
			-- Test for routine add
		local
			sprint : SPRINT
			db_handler : DB_HANDLER_SPRINT
		do
			create sprint.make ("Backlog", 10, 2)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (sprint)
				-- assert when the sprint was successfully added.
			assert ("Sprint successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the sprint added for test
			db_handler.db.rollback
		end

	update_sprint_test
			-- Test for routine update
		local
			sprint : SPRINT
			db_handler : DB_HANDLER_SPRINT
		do
			create sprint.make ("Backlog", 10, 2)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(sprint)

			sprint.set_project_duration (15)
				-- update the project in database
			db_handler.update(db_handler.db_insert_statement.last_row_id.to_natural_32,sprint)
				-- assert when the project was successfully updated.
			assert("Sprintt successfully updated", not db_handler.db_modify_statement.has_error)

				-- remove the project added for test
			db_handler.db.rollback
		end

	remove_project_test
		-- Test for routine remove
		local
			sprint : SPRINT
			db_handler : DB_HANDLER_SPRINT
			json_result : JSON_OBJECT
		do
			create sprint.make ("Backlog", 10, 2)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (sprint)

			assert("Sprint added", not db_handler.db_insert_statement.has_error)

			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32, 2)

			assert("Sprint removed ", not db_handler.db_insert_statement.has_error)

				-- remove the user added for test
			db_handler.db.rollback
		end


	total_sprints_by_status_and_project_id_test
			-- Test for routine total_tasks_by_priority_and_project_id
		local
			db_handler : DB_HANDLER_SPRINT
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_sprints_by_status_and_project_id ("Started", 1)
			assert("Count ok", json_result.item ("total_sprints").debug_output.is_equal("1"))
		end



end
