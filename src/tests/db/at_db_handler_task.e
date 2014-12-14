note
	description: "[
		Tests for routines of class DB_HANDLER_TASK
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-15$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_TASK

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_by_id_existent_task_test
			-- Test for routine find_by_id with existent task id.
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			json_result := db_handler.find_by_id (1)


				-- correct attributes
			assert("Not void", json_result /= Void)
			assert("Correct title ",json_result.item ("title").debug_output.is_equal("task1"))
			assert("Correct description ", json_result.item ("description").debug_output.is_equal("descr"))
			assert("Correct priority ", json_result.item("priority").debug_output.is_equal("Low"))
			assert("Correct position ", json_result.item("position").debug_output.is_equal("Backlog"))
			assert("Correct type ", json_result.item("type").debug_output.is_equal("Feature"))
			assert("Correct points ", json_result.item("points").debug_output.is_equal("5"))
			assert("Correct super_task_id ", json_result.item("super_task_id").debug_output.is_equal("1"))
			assert("Correct user_id", json_result.item ("user_id").debug_output.is_equal("1"))
			assert("Correct project_id", json_result.item ("project_id").debug_output.is_equal("1"))
			assert("Correct sprint_id", json_result.item ("sprint_id").debug_output.is_equal("1"))
		end

	find_by_id_nonexistent_task_test
			-- Test for routine find_by_id with nonexistent task id.
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.find_by_id (100)
			assert("Task not found", json_result.is_empty)
		end

	add_task_test
			-- Test for routine add
		local
			task: TASK
			db_handler : DB_HANDLER_TASK
		do
			create task.make (1, 1, 1, 42, "title", "desc", "Bug", "Low", "Backlog")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add_super (task)
				-- assert when the task was successfully added.
			assert ("Task successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the task added for test
			db_handler.db.rollback
		end

	add_sub_task_test
			-- Test for routine add
		local
			task: TASK
			db_handler : DB_HANDLER_TASK
		do
			create task.make_sub_task (1, 1, 1, 1, 42, "title", "desc", "Bug", "Low", "Backlog")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add_sub (task)
				-- assert when the task was successfully added.
			assert ("Task successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the task added for test
			db_handler.db.rollback
		end

	update_task_test
			-- Test for routine update
		local
			task: TASK
			db_handler : DB_HANDLER_TASK
		do
			create task.make (1, 1, 1, 42, "title", "descr", "Bug", "Low", "Backlog")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add_super (task)

			task.set_priority ("High")
				-- update the task in database
			db_handler.update(db_handler.db_insert_statement.last_row_id.to_natural_32,task)
				-- assert when the task was successfully updated.
			assert("Task successfully updated", not db_handler.db_modify_statement.has_error)

				-- remove the task added for test
			db_handler.db.rollback
		end

	remove_task_test
		-- Test for routine remove
		local
			task: TASK
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create task.make (1, 1, 1, 42, "title", "descr", "Bug", "Low", "Backlog")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add_super (task)
			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32)

				-- assert when the task was successfully removed.
			json_result := db_handler.find_by_id (db_handler.db_insert_statement.last_row_id.to_natural_32)
			assert("Task deleted", json_result.is_empty)

				-- remove the task added for test
			db_handler.db.rollback
		end

	total_points_by_project_id_test
			-- Test for routine total_points_by_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_points_by_project_id (1)
			assert("Points ok", json_result.item ("total_points").debug_output.is_equal("5"))
		end

	total_tasks_by_sprint_and_project_id_test
			-- Test for routine total_tasks_by_sprint_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_tasks_by_sprint_and_project_id (1, 1)
			assert("Count ok", json_result.item ("total_tasks").debug_output.is_equal("1"))
		end

	total_subtasks_by_sprint_and_project_id_test
			-- Test for routine total_subtasks_by_sprint_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_subtasks_by_sprint_and_project_id (1,2)
			assert("Count ok", json_result.item ("total_subtasks").debug_output.is_equal("1"))
		end

	total_points_by_sprint_and_project_id_test
			-- Test for routine total_points_by_sprint_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_points_by_sprint_and_project_id (1,3)
			assert("Points ok", json_result.item ("total_points").debug_output.is_equal("10"))
		end

	total_points_by_position_and_project_id_test
			-- Test for routine total_points_by_position_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_points_by_position_and_project_id ("Backlog", 1)
			assert("Points ok", json_result.item ("total_points").debug_output.is_equal("5"))
		end

	total_tasks_by_position_and_project_id_test
			-- Test for routine total_tasks_by_position_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_tasks_by_position_and_project_id ("Done", 3)
			assert("Count ok", json_result.item ("total_tasks_by_position").debug_output.is_equal("1"))
		end

	total_tasks_by_type_and_project_id_test
			-- Test for routine total_tasks_by_type_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_tasks_by_type_and_project_id ("Feature", 1)
			assert("Count ok", json_result.item ("total_tasks_by_type").debug_output.is_equal("1"))
		end

	total_tasks_by_priority_and_project_id_test
			-- Test for routine total_tasks_by_priority_and_project_id
		local
			db_handler : DB_HANDLER_TASK
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.total_tasks_by_priority_and_project_id ("Low", 1)
			assert("Count ok", json_result.item ("total_tasks_by_priority").debug_output.is_equal("1"))
		end
end



