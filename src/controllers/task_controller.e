note
	description: "Handlers for everything that concerns tasks."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-10$"
	revision: "$0.1$"

class
	TASK_CONTROLLER

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
			create db_handler_task.make(a_path_to_db_file)
			session_manager := a_session_manager
		end


feature {NONE} -- Private attributes

	db_handler_task : DB_HANDLER_TASK

	session_manager: WSF_SESSION_MANAGER

feature -- Handlers

	get_tasks (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all tasks
		local
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- then obtain all the tasks from the database
				l_result_payload := db_handler_task.find_all.representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the tasks
				prepare_response("User not logged in.",401,res,true)
			end
		end

	get_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json object with a task of a particular project
		local
			l_task_id: STRING
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- First we have to obtain the task id
					-- from the URL (as defined by the placeholder in the route)
				l_task_id := req.path_parameter ("task_id").string_representation

					-- Then, we return the corresponding result
				l_result_payload := db_handler_task.find_by_id(l_task_id.to_natural).representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the task
				prepare_response("User not logged in.",401,res,true)
			end
		end

	get_sub_tasks (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all subtasks out of a task
		local
			l_super_task_id: STRING
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

				-- First we have to obtain the super task id
				-- from the URL (as defined by the placeholder in the route)
				l_super_task_id := req.path_parameter ("task_id").string_representation

				-- Then, we return the corresponding result
				l_result_payload := db_handler_task.find_all_sub_tasks(l_super_task_id.to_natural).representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the tasks
				prepare_response("User not logged in.",401,res,true)
			end
		end

	add_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new task; the task data is expected to be part of the request's payload
		local
			l_payload : STRING
			new_title, new_descr, new_priority, new_position, new_type, new_sprint_id, new_user_id, new_project_id, new_points : STRING
			new_task : TASK
			parser: JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- then read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the topic data
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

						-- we have to convert the json string into an eiffel string for each topic attribute.
					if attached {JSON_STRING} j_object.item ("title") as title then
						new_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as descr then
						new_descr := descr.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("priority") as priority then
						new_priority := priority.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("position") as position then
						new_position := position.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("points") as points then
						new_points := points.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("type") as type then
						new_type := type.unescaped_string_8
					end
				end

					-- get the id of the user from the session store
				new_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out
					-- the project_id from the URL (as defined by the placeholder in the route)
			 	new_project_id := req.path_parameter ("project_id").string_representation
			 		-- and the sprint_id is setted to zero, so the task is on the project backlog by default.
			 	new_sprint_id := "0"

				create new_task.make (new_sprint_id.to_natural, new_user_id.to_natural, new_project_id.to_natural, new_points.to_natural, new_title, new_descr, new_type, new_priority, new_position)
					-- create the topic in the database
				db_handler_task.add_super (new_task)

					-- create a json object that as a "Message" property that states what happened (in the future, this should be a more meaningful messeage)
				prepare_response("Added Task "+ new_task.title,200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to add the task
				prepare_response("User not logged in.",401,res,true)
			end
		end

	add_sub_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new sub task; the task data is expected to be part of the request's payload
		local
			l_payload : STRING
			new_title, new_descr, new_priority, new_position, new_type, new_sprint_id, new_user_id, new_project_id, new_super_task_id, new_points : STRING
			new_task : TASK
			parser: JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the topic data
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

						-- we have to convert the json string into an eiffel string for each topic attribute.
					if attached {JSON_STRING} j_object.item ("title") as title then
						new_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as descr then
						new_descr := descr.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("priority") as priority then
						new_priority := priority.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("position") as position then
						new_position := position.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("project_id") as project_id then
						new_project_id := project_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("points") as points then
						new_points := points.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("type") as type then
						new_type := type.unescaped_string_8
					end
				end

					-- get the super task id from the URL
				new_super_task_id := req.path_parameter ("task_id").string_representation
					-- get the id of the user from the session store
				new_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out
					-- and the sprint_id is setted to zero, so the task is on the project backlog by default.
			 	new_sprint_id := "0"


				create new_task.make_sub_task (new_sprint_id.to_natural, new_user_id.to_natural, new_super_task_id.to_natural, new_project_id.to_natural, new_points.to_natural, new_title, new_descr, new_type, new_priority, new_position)
					-- create the topic in the database
				db_handler_task.add_sub (new_task)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Added subtask "+ new_task.title,200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to add the sub task
				prepare_response("User not logged in.",401,res,true)
			end
		end

	update_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- update a task in the database
		local
			l_payload: STRING
			l_task_id: STRING
			l_priority, l_position, l_type, l_descr, l_title, l_super_task_id, l_sprint_id, l_user_id, l_project_id, l_points : STRING
			l_task: TASK
			parser : JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- then read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the todo description and the userId
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each task attribute.
					if attached {JSON_STRING} j_object.item ("title") as title then
						l_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as descr then
						l_descr := descr.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("priority") as priority then
						l_priority := priority.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("position") as position then
						l_position := position.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("sprint_id") as sprint_id then
						l_sprint_id := sprint_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("points") as points then
						l_points := points.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("type") as type then
						l_type := type.unescaped_string_8
					end
				end

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out
					-- the project_id from the URL (as defined by the placeholder in the route)
			 	l_project_id := req.path_parameter ("project_id").string_representation
					-- then create the task
				l_super_task_id := "0" -- only for the creation procedure, this value is not updated in the database
				create l_task.make (l_sprint_id.to_natural, l_user_id.to_natural, l_project_id.to_natural, l_points.to_natural, l_title, l_descr, l_type, l_priority, l_position)

					-- get the task_id from the URL (as defined by the placeholder in the route)
				l_task_id := req.path_parameter ("task_id").string_representation


					-- and update the task in the database
				db_handler_task.update (l_task_id.to_natural,l_task)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Updated task "+ l_task.title,200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to update the task
				prepare_response("User not logged in.",401,res,true)
			end
		end


	update_sub_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- update a subtask in the database
		local
			l_payload: STRING
			l_task_id: STRING
			l_priority, l_position, l_type, l_descr, l_title, l_super_task_id, l_sprint_id, l_user_id, l_project_id, l_points : STRING
			l_task: TASK
			parser : JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- then read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the todo description and the userId
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each task attribute.
					if attached {JSON_STRING} j_object.item ("title") as title then
						l_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as descr then
						l_descr := descr.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("priority") as priority then
						l_priority := priority.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("position") as position then
						l_position := position.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("sprint_id") as sprint_id then
						l_sprint_id := sprint_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("project_id") as project_id then
						l_project_id := project_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("points") as points then
						l_points := points.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("type") as type then
						l_type := type.unescaped_string_8
					end
				end

					-- get the id of the user from the session store
				l_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out
					-- then create the task
				l_super_task_id := "0" -- only for the creation procedure, this value is not updated in the database
				create l_task.make (l_sprint_id.to_natural, l_user_id.to_natural, l_project_id.to_natural, l_points.to_natural, l_title, l_descr, l_type, l_priority, l_position)

					-- get the task_id from the URL (as defined by the placeholder in the route)
				l_task_id := req.path_parameter ("subtask_id").string_representation


					-- and update the task in the database
				db_handler_task.update (l_task_id.to_natural,l_task)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Updated subtask "+l_task.title,200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to update the sub task
				prepare_response("User not logged in.",401,res,true)
			end
		end

	remove_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a task from the database
		local
			l_task_id: STRING
		do

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- the task_id from the URL (as defined by the placeholder in the route)
				l_task_id := req.path_parameter ("task_id").string_representation
					-- remove the task
				db_handler_task.remove (l_task_id.to_natural)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Removed task",200,res,true)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to delete the task
				prepare_response("User not logged in.",401,res,true)
			end
		end

	remove_sub_task (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a subtask from the database
		local
			l_task_id: STRING
		do

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- the task_id from the URL (as defined by the placeholder in the route)
				l_task_id := req.path_parameter ("subtask_id").string_representation
					-- remove the sub task
				db_handler_task.remove (l_task_id.to_natural)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Removed subtask",200,res,true)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to delete the sub task
				prepare_response("User not logged in.",401,res,true)
			end
		end


end


