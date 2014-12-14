note
	description: "Handlers for everything that concerns sprints."
	author: "$Rio Cuarto4 Team$"
	date: "$2014-11-11$"
	revision: "$0.1$"

class
	SPRINT_CONTROLLER

inherit
	HEADER_JSON_HELPER
		-- inherit this helper to get a procedure that simplifies setting
		-- the HTTP response header correctly

	SESSION_HELPER
		-- inherit this helper to get functions to check for a session cookie
		-- if a session cookie exists, we can get the data of that session

create
	make


feature {NONE} -- Creation

	make (a_path_to_db_file: STRING; a_session_manager: WSF_SESSION_MANAGER)
		do
			create db_handler_sprint.make (a_path_to_db_file)
			create db_handler_project.make (a_path_to_db_file)
			create db_handler_task.make (a_path_to_db_file)

			session_manager := a_session_manager
		end


feature {NONE} -- Private attributes

	db_handler_sprint : DB_HANDLER_SPRINT
	db_handler_project: DB_HANDLER_PROJECT
	db_handler_task: DB_HANDLER_TASK

	session_manager: WSF_SESSION_MANAGER

feature -- Handlers

	get_sprints (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all sprints
		local
			l_result_payload: STRING
		do
			l_result_payload := db_handler_sprint.find_all.representation

			prepare_response(l_result_payload,200,res,false)
		end


	get_sprint (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json object with a sprint with given id
		local
			l_result_payload: STRING
			l_sprint_id: STRING;
			l_project_id : STRING
		do

			-- the project_id from the URL
			l_project_id := req.path_parameter ("project_id").string_representation

			-- the sprint_id from the URL
			l_sprint_id := req.path_parameter ("sprint_id").string_representation

			l_result_payload := db_handler_sprint.find_by_id_and_project_id (l_sprint_id.to_integer, l_project_id.to_integer).representation

			prepare_response(l_result_payload,200,res,false)
		end


	add_sprint (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new sprint; the sprint data are expected to be part of the request's payload
		local
			l_payload : STRING
			new_status, new_duration: STRING
			project_id: STRING
			new_sprint: SPRINT
			parser: JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

				-- read the payload from the request and store it in the string
			req.read_input_data_into (l_payload)

				-- now parse the json object that we got as part of the payload
			create parser.make_parser (l_payload)

				-- if the parsing was successful and we have a json object, we fetch the properties
				-- for the sprint description
			if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each sprint attribute.
				if attached {JSON_STRING} j_object.item ("status") as status then
					new_status := status.unescaped_string_8
				end
				if attached {JSON_STRING} j_object.item ("duration") as duration then
					new_duration := duration.unescaped_string_8
				end
			end

			-- obtain the project id via the URL
			project_id := req.path_parameter ("project_id").string_representation

			create new_sprint.make (new_status, new_duration.to_natural, project_id.to_natural)

				-- create the sprint in the database
			db_handler_sprint.add (new_sprint)

				-- prepare the reponse
			prepare_response("Added sprint",200,res,true)
		end


	update_sprint (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- update a sprint from the database
		local
			l_payload: STRING
			l_sprint_id, l_sprint_project_id: STRING
			sprint_status, sprint_duration : STRING
			sprint: SPRINT
			parser : JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

				-- read the payload from the request and store it in the string
			req.read_input_data_into (l_payload)

				-- now parse the json object that we got as part of the payload
			create parser.make_parser (l_payload)

				-- if the parsing was successful and we have a json object, we fetch the properties
				-- for the sprint description
			if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

				-- we have to convert the json string into an eiffel string for each sprint attribute.
				if attached {JSON_STRING} j_object.item ("status") as status then
					sprint_status := status.unescaped_string_8
				end
				if attached {JSON_STRING} j_object.item ("duration") as duration then
					sprint_duration := duration.unescaped_string_8
				end

			end

				-- the project_id from the URL (as defined by the placeholder in the route)
			l_sprint_project_id := req.path_parameter ("project_id").string_representation


				-- the sprint_id from the URL (as defined by the placeholder in the route)
			l_sprint_id := req.path_parameter ("sprint_id").string_representation

				-- create the sprint
			create sprint.make (sprint_status, sprint_duration.to_natural, l_sprint_project_id.to_natural)

				-- update the sprint in the database
			db_handler_sprint.update (l_sprint_id.to_natural,sprint)

				-- prepare the reponse
			prepare_response("Updated sprint "+ l_sprint_id.out,200,res,true)
		end


	remove_sprint (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a sprint from the database
		local
			l_sprint_id, l_sprint_project_id: STRING
		do
				-- the project_id from the URL (as defined by the placeholder in the route)
			l_sprint_project_id := req.path_parameter ("project_id").string_representation

				-- the sprint_id from the URL (as defined by the placeholder in the route)
			l_sprint_id := req.path_parameter ("sprint_id").string_representation

				-- remove the sprint
			db_handler_sprint.remove (l_sprint_id.to_natural, l_sprint_project_id.to_natural)

				-- prepare the reponse
			prepare_response("Removed item",200,res,true)

		end


	remove_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a task from the database
		local
			l_task_id: STRING
		do

				-- the task_id from the URL (as defined by the placeholder in the route)
			l_task_id := req.path_parameter ("task_id").string_representation

				-- remove the task
			db_handler_task.remove (l_task_id.to_natural)

				-- prepare the reponse
			prepare_response("Removed item",200,res,true)
		end


end
