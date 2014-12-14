note
	description: "Handlers for everything that concerns reports."
	author: "$Rio Cuarto4 Team$"
	date: "$2014-12-01$"
	revision: "$0.1$"

class
	REPORT_CONTROLLER

inherit

	HEADER_JSON_HELPER
		-- inherit this helper to get a procedure that simplifies setting
		-- the HTTP response header correctly

	SESSION_HELPER
		-- inherit this helper to get functions to check for a session cookie
		-- if a session cookie exists, we can get the data of that session

create
	make

feature {NONE} -- Initialization

	make (a_path_to_db_file: STRING; a_session_manager: WSF_SESSION_MANAGER)
		do
			create db_handler_project.make (a_path_to_db_file)
			create db_handler_sprint.make (a_path_to_db_file)
			create db_handler_task.make (a_path_to_db_file)
			create db_handler_user.make (a_path_to_db_file)

			session_manager := a_session_manager
		end

feature -- Operations

	get_report(req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response containing a json object with all data necessary for report generation
		local
			l_result_payload: STRING
			l_result: JSON_OBJECT
			total_sprints_completed, total_sprints_backlog, total_sprints_started, total_sprint_points : JSON_OBJECT
			total_tasks_by_sprint, total_subtasks_by_sprint, total_task_points : JSON_OBJECT
			total_task_points_backlog, total_task_points_process, total_task_points_done, total_task_points_testing, total_task_points_canceled: JSON_OBJECT
			total_tasks_backlog, total_tasks_process, total_tasks_done, total_tasks_testing, total_tasks_canceled: JSON_OBJECT
			total_bug_tasks, total_feature_tasks : JSON_OBJECT
			total_high_tasks, total_normal_tasks, total_low_tasks: JSON_OBJECT
			total_amount_of_sprints, i: NATURAL
			project_id : STRING
		do
			create l_result_payload.make_empty
			create l_result.make

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

					-- obtain the project id from the url
				project_id := req.path_parameter ("project_id").string_representation

					-- assign a json per data needed to generate a project

					-- sprint data:
				total_amount_of_sprints := db_handler_sprint.total_sprints_by_project_id (project_id.to_natural).item ("total_sprints").representation.at (2).out.to_natural
				total_sprints_completed := db_handler_sprint.total_sprints_by_status_and_project_id ("Complete", project_id.to_natural)
				total_sprints_started := db_handler_sprint.total_sprints_by_status_and_project_id ("Started", project_id.to_natural)
				total_sprints_backlog := db_handler_sprint.total_sprints_by_status_and_project_id ("Backlog", project_id.to_natural)
					-- task data:
				total_task_points := db_handler_task.total_points_by_project_id (project_id.to_natural)
				total_task_points_backlog := db_handler_task.total_points_by_position_and_project_id ("Backlog", project_id.to_natural)
				total_task_points_process := db_handler_task.total_points_by_position_and_project_id ("Process", project_id.to_natural)
				total_task_points_done := db_handler_task.total_points_by_position_and_project_id ("Done", project_id.to_natural)
				total_task_points_canceled := db_handler_task.total_points_by_position_and_project_id ("Canceled", project_id.to_natural)
				total_task_points_testing := db_handler_task.total_points_by_position_and_project_id ("Testing", project_id.to_natural)

				total_tasks_backlog := db_handler_task.total_tasks_by_position_and_project_id ("Backlog", project_id.to_natural)
				total_tasks_process := db_handler_task.total_tasks_by_position_and_project_id ("Process", project_id.to_natural)
				total_tasks_done := db_handler_task.total_tasks_by_position_and_project_id ("Done", project_id.to_natural)
				total_tasks_canceled := db_handler_task.total_tasks_by_position_and_project_id ("Canceled", project_id.to_natural)
				total_tasks_testing := db_handler_task.total_tasks_by_position_and_project_id ("Testing", project_id.to_natural)

				total_bug_tasks := db_handler_task.total_tasks_by_type_and_project_id ("Bug", project_id.to_natural)
				total_feature_tasks := db_handler_task.total_tasks_by_type_and_project_id ("Feature", project_id.to_natural)

				total_high_tasks := db_handler_task.total_tasks_by_priority_and_project_id ("High", project_id.to_natural)
				total_low_tasks := db_handler_task.total_tasks_by_priority_and_project_id ("Low", project_id.to_natural)
				total_normal_tasks := db_handler_task.total_tasks_by_priority_and_project_id ("Normal", project_id.to_natural)

					-- data for each sprint
				from
					i := 1
				until
					i > total_amount_of_sprints
				loop
					total_tasks_by_sprint := db_handler_task.total_tasks_by_sprint_and_project_id (i, project_id.to_natural)
					total_subtasks_by_sprint := db_handler_task.total_subtasks_by_sprint_and_project_id (i, project_id.to_natural)
					total_sprint_points := db_handler_task.total_points_by_sprint_and_project_id (i, project_id.to_natural)
					l_result.put (total_tasks_by_sprint.item("total_tasks"), "total_sprint_"+i.out+"_tasks")
					l_result.put (total_subtasks_by_sprint.item ("total_subtasks"), "total_sprint_"+i.out+"_subtasks")
					l_result.put (total_sprint_points.item ("total_points"), "total_sprint_"+i.out+"_points")
					i := i + 1
				end


					-- then put each json value into a new json that contains every value for better organization
					-- tasks:
				l_result.put (total_task_points.item ("total_points"), "total_task_points")
				l_result.put (total_task_points_backlog.item ("total_points"), "total_tasks_points_backlog")
				l_result.put (total_task_points_canceled.item ("total_points"), "total_tasks_points_canceled")
				l_result.put (total_task_points_done.item ("total_points"), "total_tasks_points_done")
				l_result.put (total_task_points_process.item ("total_points"), "total_tasks_points_process")
				l_result.put (total_task_points_testing.item ("total_points"), "total_tasks_points_testing")

				l_result.put (total_tasks_backlog.item ("total_tasks_by_position"), "total_tasks_backlog")
				l_result.put (total_tasks_canceled.item ("total_tasks_by_position"), "total_tasks_canceled")
				l_result.put (total_tasks_done.item ("total_tasks_by_position"), "total_tasks_done")
				l_result.put (total_tasks_process.item ("total_tasks_by_position"), "total_tasks_process")
				l_result.put (total_tasks_testing.item ("total_tasks_by_position"), "total_tasks_testing")

				l_result.put (total_bug_tasks.item ("total_tasks_by_type"), "total_bug_tasks")
				l_result.put (total_feature_tasks.item ("total_tasks_by_type"), "total_feature_tasks")

				l_result.put (total_high_tasks.item ("total_tasks_by_priority"), "total_high_tasks")
				l_result.put (total_normal_tasks.item ("total_tasks_by_priority"), "total_normal_tasks")
				l_result.put (total_low_tasks.item ("total_tasks_by_priority"), "total_low_tasks")
					-- sprints:
				l_result.put (total_sprints_completed.item ("total_sprints"), "total_sprints_completed")
				l_result.put (total_sprints_started.item ("total_sprints"), "total_sprints_started")
				l_result.put (total_sprints_backlog.item ("total_sprints"), "total_sprints_backlog")


				l_result_payload := l_result.representation
				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to generate a project.
				prepare_response("User is not logged in",401,res,true)
			end
		end

feature {NONE} -- Private attributes

	db_handler_project : DB_HANDLER_PROJECT
	db_handler_sprint: DB_HANDLER_SPRINT
	db_handler_task: DB_HANDLER_TASK
	db_handler_user: DB_HANDLER_USER

	session_manager: WSF_SESSION_MANAGER


end
