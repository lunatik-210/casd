note
	description: "This class manages the database operations that concerns tasks."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-08$"
	revision: "$0.01$"

class
	DB_HANDLER_TASK

inherit
	CASD_DB

create
	make

feature -- Data access

	find_all : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a task
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Tasks;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 11, Result))
		end

	find_all_sub_tasks (a_super_task_id: NATURAL) : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a subtask of the desired task
		do
			create Result.make_array
			-- a super task has itself as a super task, so we exclude that value from the subtasks.
			create db_query_statement.make ("SELECT * FROM Tasks WHERE super_task_id=" + a_super_task_id.out + " AND (NOT " + a_super_task_id.out + " = id) ;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 11, Result))
		end

	find_by_id (a_task_id : NATURAL) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents a task that corresponds to the given id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Tasks WHERE id=" + a_task_id.out + ";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 11, Result))
		ensure
			correct_id: (Result.item ("id").debug_output.is_equal(a_task_id.out))
		end

	find_by_project_id (a_project_id : NATURAL) : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a task of the given project
		do
			create Result.make_array
			create db_query_statement.make("SELECT * FROM Tasks WHERE project_id=" + a_project_id.out + ";" ,db)
			db_query_statement.execute (agent rows_to_json_array (?, 11, Result))
		end

	add_super(a_task: TASK)
			-- Adds a task
		require
			task_not_void: (a_task /= Void)
		do
			create db_insert_statement.make ("INSERT INTO Tasks(priority,position,type,description,title,points,sprint_id,project_id,user_id) VALUES ('" + a_task.priority + "','" + a_task.position + "','" + a_task.type + "','" + a_task.description + "','" + a_task.title + "','" + a_task.points.out + "','" + a_task.sprint_id.out + "','" + a_task.project_id.out + "','" + a_task.user_id.out + "');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new topic")
			end
			-- After creating a super task, the super_task_id value must be set properly.
			-- Here we use the id of the task just created.
			create db_modify_statement.make ("UPDATE Tasks SET super_task_id = " + db_insert_statement.last_row_id.out + " WHERE id = " + db_insert_statement.last_row_id.out + ";" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while inserting a new task. (super_task_id not set)")
			end
		end

	add_sub(a_task: TASK)
			-- Adds a sub task
		require
			subtask_not_void: (a_task /= Void)
		do
			create db_insert_statement.make ("INSERT INTO Tasks(priority,position,type,description,title,points,super_task_id,sprint_id,project_id,user_id) VALUES ('" + a_task.priority + "','" +
																																						       a_task.position + "','" +
																																						       a_task.type + "','" +
																																						       a_task.description + "','" +
																																						       a_task.title + "','" +
																																						       a_task.points.out + "','" +
																																						       a_task.super_task_id.out + "','" +
																																						       a_task.sprint_id.out + "','" +
																																						       a_task.project_id.out + "','" +
																																						       a_task.user_id.out + "');", db)
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new topic")
			end
		end

	update (task_id : NATURAL; task: TASK)
			-- Update a task
		require
			task_not_void: (task /= Void)
		do
				create db_modify_statement.make ("UPDATE Tasks SET priority = '"+ task.priority +"',"+
																  "position = '"+ task.position +"',"+
																  "type = '"+ task.type +"',"+
																  "description = '"+ task.description +"',"+
																  "title = '"+ task.title +"',"+
																  "points = '"+ task.points.out +"',"+
																  "sprint_id = '"+ task.sprint_id.out +"',"+
																  "project_id = '"+ task.project_id.out +"',"+
																  "user_id = '"+ task.user_id.out +"'"+
																  "WHERE id="+ task_id.out +";" , db)
				db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating a task")
			end
		end

	remove (task_id: NATURAL)
			-- removes the task with the given id
		do
			create db_modify_statement.make ("DELETE FROM Tasks WHERE id=" + task_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a task")
					-- TODO: we probably want to return something if there's an error
			end
		end

feature -- Data access for reports

	total_points_by_project_id (project_id: NATURAL) : JSON_OBJECT
			-- returns the sum of the points of the tasks related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT TOTAL(points) AS total_points FROM tasks WHERE project_id="+ project_id.out +";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_tasks_by_sprint_and_project_id (sprint_id,project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of tasks related to a given sprint of a project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_tasks FROM tasks WHERE sprint_id="+ sprint_id.out +" AND project_id="+ project_id.out +";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_subtasks_by_sprint_and_project_id (sprint_id,project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of subtasks related to a given sprint of a project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_subtasks FROM tasks WHERE sprint_id="+ sprint_id.out +" AND project_id="+project_id.out+" AND NOT id = super_task_id;",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_points_by_sprint_and_project_id (sprint_id,project_id: NATURAL) : JSON_OBJECT
			-- returns the sum of the points of the tasks related to a given sprint of a project
		do
			create Result.make
			create db_query_statement.make("SELECT TOTAL(points) AS total_points FROM tasks WHERE sprint_id="+sprint_id.out+" AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_points_by_position_and_project_id (position: STRING;project_id: NATURAL) : JSON_OBJECT
			-- returns the sum of the points of the tasks which position is 'position' related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT TOTAL(points) AS total_points FROM tasks WHERE position='"+position+"' AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_tasks_by_position_and_project_id (position: STRING;project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of tasks which position is 'position' related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_tasks_by_position FROM tasks WHERE position='"+ position +"' AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_tasks_by_type_and_project_id (type: STRING;project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of tasks which type is 'type' related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_tasks_by_type FROM tasks WHERE type='"+ type +"' AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_tasks_by_priority_and_project_id (priority: STRING;project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of tasks which priority is 'priority' related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_tasks_by_priority FROM tasks WHERE priority='"+ priority +"' AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

end

