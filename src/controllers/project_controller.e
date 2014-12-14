note
	description: "Handlers for everything that concerns projects."
	author: "$Rio Cuarto4 Team$"
	date: "$2014-11-11$"
	revision: "$0.1$"

class
	PROJECT_CONTROLLER

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
			create db_handler_project.make (a_path_to_db_file)
			create db_handler_sprint.make (a_path_to_db_file)
			create db_handler_task.make (a_path_to_db_file)
			create db_handler_user.make (a_path_to_db_file)

			session_manager := a_session_manager
		end


feature {NONE} -- Private attributes

	db_handler_project : DB_HANDLER_PROJECT
	db_handler_sprint: DB_HANDLER_SPRINT
	db_handler_task: DB_HANDLER_TASK
	db_handler_user: DB_HANDLER_USER

	session_manager: WSF_SESSION_MANAGER


feature -- Handlers

	get_projects (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all projects
		local
			l_result_payload: STRING
			l_user_id: STRING
			l_result: JSON_OBJECT
		do
			create l_result.make

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- get all project where the user is owner or collaborator
				l_result_payload := db_handler_project.find_by_user_loged (l_user_id.to_integer).representation

				prepare_response(l_result_payload,200,res,false)

			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


	get_project (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json object with a project with given id
		local
			l_result_payload: STRING
			l_project_id : STRING
		do
			-- the project_id from the URL
			l_project_id := req.path_parameter ("project_id").string_representation

			l_result_payload := db_handler_project.find_by_id (l_project_id.to_integer).representation

			prepare_response(l_result_payload,200,res,false)
		end


	get_collaborators (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json array with all users (collaborators) of a project
		local
			project_id: STRING
			l_result_payload: STRING
		do
			-- obtain the project id via the URL
			project_id := req.path_parameter ("project_id").string_representation

			-- and use the user handler to obtain all its collaborators
			l_result_payload := db_handler_user.find_by_project_id (project_id.to_natural).representation

			prepare_response(l_result_payload,200,res,false)
		end


	get_sprints (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json array with all sprints of a project
		local
			project_id: STRING
			l_result_payload: STRING
		do
			-- obtain the project id via the URL
			project_id := req.path_parameter ("project_id").string_representation

			-- and use the sprint handler to obtain all its sprints
			l_result_payload := db_handler_sprint.find_by_project_id (project_id.to_natural).representation

			prepare_response(l_result_payload,200,res,false)
		end

	get_tasks (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json array with all tasks of a project
		local
			project_id: STRING
			l_result_payload: STRING
		do
			-- obtain the project id via the URL
			project_id := req.path_parameter ("project_id").string_representation

			-- and use the sprint handler to obtain all its sprints
			l_result_payload := db_handler_task.find_by_project_id (project_id.to_natural).representation

			prepare_response(l_result_payload,200,res,false)
		end


	add_project (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new project; the project data are expected to be part of the request's payload
		local
			l_payload, l_user_id : STRING
			new_name, new_status, new_description, new_mpps: STRING
			new_project : PROJECT
			parser: JSON_PARSER
			l_result: JSON_OBJECT
		do
				-- create emtpy string objects
			create l_payload.make_empty

				-- create json object
			create l_result.make


			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the project description
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

						-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("name") as name then
						new_name := name.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("status") as status then
						new_status := status.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as description then
						new_description := description.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("max_points_per_sprint") as mpps then
						new_mpps := mpps.unescaped_string_8
					end
				end


				create new_project.make (new_name, new_status, new_description, new_mpps.to_natural, l_user_id.to_natural)

					-- create the project in the database
				db_handler_project.add (new_project)

					-- prepare the response
				prepare_response("Added project " + new_project.name,200,res,true)

			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end

		end


	add_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new task; the task data are expected to be part of the request's payload
		local
			l_payload : STRING
			new_priority, new_position, new_type, new_description, new_title, new_points : STRING
			new_super_task_id, new_sprint_id: STRING
			l_project_id,l_user_id: STRING
			new_task : TASK
			parser: JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the project description
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

						-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("priority") as priority then
						new_priority := priority.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("position") as position then
						new_position := position.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("type") as type then
						new_type := type.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as description then
						new_description := description.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("title") as title then
						new_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("points") as points then
						new_points := points.unescaped_string_8
					end
				end

					-- obtain the project id via the URL
				l_project_id := req.path_parameter ("project_id").string_representation
					-- and the sprint_id is setted to zero, so the task is on the project backlog by default.
			 	new_sprint_id := "0"

				create new_task.make (new_sprint_id.to_natural, l_user_id.to_natural, l_project_id.to_natural, new_points.to_natural, new_title, new_description, new_type, new_priority, new_position)

					-- create the task in the database
				db_handler_task.add_super (new_task)

				prepare_response("Added task " + new_task.title,200,res,true)

			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


	add_collaborator (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new project; the project data are expected to be part of the request's payload
		local
			l_user_id_to_add, l_project_id, l_owner_user_id: STRING
			l_result, l_aux: JSON_OBJECT
			obtained_id: STRING

		do
			create l_result.make

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_owner_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- obtain the project id via the URL
				l_project_id := req.path_parameter ("project_id").string_representation


					-- obtain the user id via the URL
				l_user_id_to_add := req.path_parameter ("user_id").string_representation


				l_aux := db_handler_project.find_owner (l_project_id.to_integer)

				if attached {JSON_OBJECT} l_aux as j_object then

						-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("user_id") as id then
						obtained_id := id.unescaped_string_8
					end
				end


				if l_owner_user_id.is_equal (obtained_id) then

						-- create the collaborator in the database
					db_handler_project.add_collaborator (l_user_id_to_add.to_natural, l_project_id.to_natural)

					prepare_response("Added collaborator",200,res,true)
				else
						-- the user logged isnt the project owner
						-- we return an error stating that the user is not authorized to get the users.
					prepare_response("The user loged isnt the project owner",401,res,true)
				end
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


	update_project (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- update a project from the database
		local
			l_payload: STRING
			l_project_id, l_user_id: STRING
			project_name, project_status, project_description, project_mpps: STRING
			project : PROJECT
			parser : JSON_PARSER
			l_result: JSON_OBJECT
		do
				-- create emtpy string objects
			create l_payload.make_empty

				-- create json object
			create l_result.make


			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the project description
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("name") as name then
						project_name := name.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("status") as status then
						project_status := status.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as description then
						project_description := description.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("max_points_per_sprint") as mpps then
						project_mpps := mpps.unescaped_string_8
					end
				end

					-- create the project
				create project.make (project_name, project_status, project_description, project_mpps.to_natural,l_user_id.to_natural)

					-- the project_id from the URL (as defined by the placeholder in the route)
				l_project_id := req.path_parameter ("project_id").string_representation


					-- update the project in the database
				db_handler_project.update (l_project_id.to_natural,project)

				prepare_response("Updated project "+ project.name,200,res,true)

			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


	remove_project (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a project from the database
		local
			l_project_id, l_owner_user_id, obtained_id: STRING
			l_aux: JSON_OBJECT
		do
			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_owner_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- the project_id from the URL (as defined by the placeholder in the route)
				l_project_id := req.path_parameter ("project_id").string_representation

					-- find project owner from the database
				l_aux := db_handler_project.find_owner (l_project_id.to_integer)

				if attached {JSON_OBJECT} l_aux as j_object then

						-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("user_id") as id then
						obtained_id := id.unescaped_string_8
					end
				end

				if l_owner_user_id.is_equal (obtained_id) then

						-- remove the project
					db_handler_project.remove (l_project_id.to_natural)

						-- prepare response
					prepare_response("Removed item",200,res,true)
				else
						-- the user logged isnt the project owner
						-- we return an error stating that the user is not authorized to get the users.
					prepare_response("The user loged isnt the project owner",401,res,true)
				end
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


	remove_collaborator (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a project from the database
		local
			l_user_id, l_project_id, l_owner_user_id, obtained_id: STRING
			l_aux: JSON_OBJECT
		do

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				l_owner_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- the project_id from the URL (as defined by the placeholder in the route)
				l_project_id := req.path_parameter ("project_id").string_representation

					-- find project owner from the database
				l_aux := db_handler_project.find_owner (l_project_id.to_integer)

				if attached {JSON_OBJECT} l_aux as j_object then

						-- we have to convert the json string into an eiffel string for each project attribute.
					if attached {JSON_STRING} j_object.item ("user_id") as id then
						obtained_id := id.unescaped_string_8
					end
				end


				if l_owner_user_id.is_equal (obtained_id) then

						-- the user_id from the URL (as defined by the placeholder in the route)
					l_user_id := req.path_parameter ("user_id").string_representation

						-- remove the collaborator
					db_handler_project.remove_collaborator (l_user_id.to_natural, l_project_id.to_natural)

						-- prepare response
					prepare_response("Removed item",200,res,true)

				else
						-- the user logged isnt the project owner
						-- we return an error stating that the user is not authorized to get the users.
					prepare_response("The user loged isnt the project owner",401,res,true)
				end
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end


end
