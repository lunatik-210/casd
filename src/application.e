note
	description : "CASD application root class"
	date        : "$2014-11-08$"
	revision    : "$0.1$"

class
	APPLICATION

inherit
	WSF_DEFAULT_SERVICE
		redefine
			initialize
		end

	WSF_ROUTED_SERVICE
		-- a routed_service implements the execute loop
		-- but it expectes us to implement

	WSF_URI_TEMPLATE_HELPER_FOR_ROUTED_SERVICE
		-- for the routing we use uri templates
		-- thus we can have "varialbes" in the uris

create
	make_and_launch


feature {NONE} -- Initialization

	path_to_db_file: STRING
		-- calculates the path to the demo.db file, based on the location of the .ecf file
		-- Note: we used to have a fixed path here but this way it should work out-of-box for everyone
		once
			Result := ".." + Operating_environment.directory_separator.out + "casd.db"
		end

	path_to_www_folder: STRING
		-- calculates the path to the www folder, based on the location of the .ecf file
		-- Note: we used to have a fixed path here but this way it should work out-of-box for everyone
		once
			Result := ".." + Operating_environment.directory_separator.out + "www"
		end

		-- controllers and other helpers
	user_ctrl: USER_CONTROLLER
	project_ctrl: PROJECT_CONTROLLER
	sprint_ctrl: SPRINT_CONTROLLER
	answer_ctrl: ANSWER_CONTROLLER
	topic_ctrl: TOPIC_CONTROLLER
	task_ctrl: TASK_CONTROLLER
	report_ctrl: REPORT_CONTROLLER
	session_manager: WSF_FS_SESSION_MANAGER

	initialize
			-- Initialize current service.
		do
				-- create the dao object and the controllers
				-- we reuse the same database connection so we don't open up too many connections at once
			create session_manager.make
			create user_ctrl.make (path_to_db_file,session_manager)
			create project_ctrl.make (path_to_db_file,session_manager)
			create sprint_ctrl.make (path_to_db_file,session_manager)
			create answer_ctrl.make (path_to_db_file,session_manager)
			create topic_ctrl.make (path_to_db_file,session_manager)
			create task_ctrl.make (path_to_db_file,session_manager)
			create report_ctrl.make (path_to_db_file, session_manager)
				-- set the prot of the web server to 9090
			set_service_option ("port", 9090)

				-- initialize the router
			initialize_router
		end

feature -- Basic operations

	setup_router
		local
			fhdl: WSF_FILE_SYSTEM_HANDLER
		do

				-- handling of all the routes relating to "sessions"
			map_uri_template_agent_with_request_methods ("/api/sessions", agent user_ctrl.login , router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/sessions", agent user_ctrl.logout , router.methods_delete)

				-- handling of all the routes relating to "users"
			map_uri_template_agent_with_request_methods ("/api/user", agent user_ctrl.get_logged_user, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/users", agent user_ctrl.get_users, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/users", agent user_ctrl.add_user, router.methods_post )
			map_uri_template_agent_with_request_methods ("/api/users/{user_id}", agent user_ctrl.get_user, router.methods_get )
			map_uri_template_agent_with_request_methods ("/api/users/{user_id}", agent user_ctrl.update_user, router.methods_post )
			map_uri_template_agent_with_request_methods ("/api/users/{user_id}", agent user_ctrl.remove_user, router.methods_delete )

				-- handling of all the routes relating to "projects"
			map_uri_template_agent_with_request_methods ("/api/projects", agent project_ctrl.get_projects, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects", agent project_ctrl.add_project, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}", agent project_ctrl.get_project, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}", agent project_ctrl.update_project, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}", agent project_ctrl.remove_project, router.methods_delete)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/collaborators", agent project_ctrl.get_collaborators, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/collaborators/{user_id}", agent project_ctrl.add_collaborator, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/collaborators/{user_id}", agent project_ctrl.remove_collaborator, router.methods_delete)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints", agent project_ctrl.get_sprints, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/tasks", agent project_ctrl.get_tasks, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/tasks", agent project_ctrl.add_task, router.methods_post)

				-- handling of all the routes relating to "sprints"
			map_uri_template_agent_with_request_methods ("/api/sprints", agent sprint_ctrl.get_sprints, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints", agent sprint_ctrl.add_sprint, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints/{sprint_id}", agent sprint_ctrl.get_sprint, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints/{sprint_id}", agent sprint_ctrl.update_sprint, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints/{sprint_id}", agent sprint_ctrl.remove_sprint, router.methods_delete)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/sprints/{sprint_id}/tasks/{task_id}", agent sprint_ctrl.remove_task, router.methods_delete)

				-- handling of all the routes relating to "topics"
			map_uri_template_agent_with_request_methods ("/api/topics", agent topic_ctrl.get_topics, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/topics", agent topic_ctrl.add_topic, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}", agent topic_ctrl.get_topic, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}", agent topic_ctrl.update_topic, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}", agent topic_ctrl.remove_topic, router.methods_delete)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}/answers", agent topic_ctrl.get_answers, router.methods_get)

				-- handling of all the routes relating to "answers"
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}/answers", agent answer_ctrl.add_answer, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}/answers/{answer_id}", agent answer_ctrl.update_answer, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/topics/{topic_id}/answers/{answer_id}", agent answer_ctrl.remove_answer, router.methods_delete)

				-- handling of all the routes relating to "tasks"
			map_uri_template_agent_with_request_methods ("/api/tasks", agent task_ctrl.get_tasks, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/tasks/{task_id}", agent task_ctrl.get_task, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/tasks/{task_id}", agent task_ctrl.update_task, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/tasks/{task_id}", agent task_ctrl.remove_task, router.methods_delete)

			map_uri_template_agent_with_request_methods ("/api/tasks/{task_id}/subtasks", agent task_ctrl.get_sub_tasks, router.methods_get)
			map_uri_template_agent_with_request_methods ("/api/tasks/{task_id}/subtasks", agent task_ctrl.add_sub_task, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/tasks/{task_id}/subtasks/{subtask_id}", agent task_ctrl.update_sub_task, router.methods_post)
			map_uri_template_agent_with_request_methods ("/api/tasks/{task_id}/subtasks/{subtask_id}", agent task_ctrl.remove_sub_task, router.methods_delete)

			-- handling of all the routes relating to "reports"
			map_uri_template_agent_with_request_methods ("/api/projects/{project_id}/reports", agent report_ctrl.get_report, router.methods_get)


				-- setting the path to the folder from where we serve static files
			create fhdl.make_hidden (path_to_www_folder)
			fhdl.set_directory_index (<<"index.html">>)
			router.handle_with_request_methods ("", fhdl, router.methods_GET)
		end

end
