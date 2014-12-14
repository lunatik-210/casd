note
	description: "Handlers for everything that concerns topics."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-08$"
	revision: "$0.1$"

class
	TOPIC_CONTROLLER

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
			create db_handler_topic.make(a_path_to_db_file)
			create db_handler_answer.make(a_path_to_db_file)
			session_manager := a_session_manager
		end


feature {NONE} -- Private attributes

	db_handler_topic : DB_HANDLER_TOPIC
	db_handler_answer : DB_HANDLER_ANSWER
	session_manager: WSF_SESSION_MANAGER

feature -- Handlers

	get_topics (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all topics
		local
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

				l_result_payload := db_handler_topic.find_all.representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the topics
				prepare_response("User not logged in.",401,res,true)
			end
		end

	get_topic (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json with a topic
		local
			topic_id : STRING
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- then, obtain the topic id via the URL
				topic_id := req.path_parameter ("topic_id").string_representation
				l_result_payload := db_handler_topic.find_by_id (topic_id.to_natural).representation

				prepare_response(l_result_payload,200,res,false)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the topic
				prepare_response("User not logged in.",401,res,true)
			end
		end

	get_answers (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json array with all answers of a topic
		local
			topic_id: STRING
			l_result_payload: STRING
		do
			create l_result_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in

					-- obtain the topic id via the URL
				topic_id := req.path_parameter ("topic_id").string_representation
					-- and use the answer handler to obtain all its answers
				l_result_payload := db_handler_answer.find_by_topic_id (topic_id.to_natural).representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to get the answers
				prepare_response("User not logged in.",401,res,true)
			end
		end

	add_topic (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new topic; the topic data is expected to be part of the request's payload
		local
			l_payload : STRING
			new_title, new_descr, new_project_id, new_task_id, new_user_id, new_sprint_id : STRING
			new_topic : TOPIC
			parser: JSON_PARSER
		do
			-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- get the id of the user from the session store
				new_user_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

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
					if attached {JSON_STRING} j_object.item ("project_id") as project_id then
						new_project_id := project_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("task_id") as task_id then
						new_task_id := task_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("sprint_id") as sprint_id then
						new_sprint_id := sprint_id.unescaped_string_8
					end

				end

				create new_topic.make(new_project_id.to_natural, new_task_id.to_natural, new_sprint_id.to_natural , new_user_id.to_natural, new_title, new_descr)
					-- create the topic in the database
				db_handler_topic.add (new_topic, new_user_id.to_natural, new_project_id.to_natural, new_task_id.to_natural, new_sprint_id.to_natural)

					-- create a json object that as a "Message" property that states what happend (in the future, this should be a more meaningful messeage)
				prepare_response("Added topic "+new_topic.title,200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to add a topic
				prepare_response("User not logged in.",401,res,true)
			end

		end

	update_topic (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- update a topic from the database
		local
			l_payload: STRING
			l_topic_id: STRING
			l_project_id, l_answered, l_descr, l_title, l_task_id, l_sprint_id, l_user_id : STRING
			l_topic: TOPIC
			parser : JSON_PARSER
		do
				-- create emtpy string objects
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- read the payload from the request and store it in the string
				req.read_input_data_into (l_payload)

					-- now parse the json object that we got as part of the payload
				create parser.make_parser (l_payload)

					-- if the parsing was successful and we have a json object, we fetch the properties
					-- for the topic data
				if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each task attribute.
					if attached {JSON_STRING} j_object.item ("title") as title then
						l_title := title.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("description") as descr then
						l_descr := descr.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("answered") as answered then
						l_answered := answered.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("project_id") as project_id then
						l_project_id := project_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("sprint_id") as sprint_id then
						l_sprint_id := sprint_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("user_id") as user_id then
						l_user_id := user_id.unescaped_string_8
					end
					if attached {JSON_STRING} j_object.item ("task_id") as task_id then
						l_task_id := task_id.unescaped_string_8
					end
				end

					-- check if the user_id matches with the logged user_id
				if (l_user_id.is_equal (get_session_from_req (req, "_casd_session_").at ("user_id").out)) then

						-- create the topic
					create l_topic.make (l_project_id.to_natural, l_task_id.to_natural, l_sprint_id.to_natural, l_user_id.to_natural, l_title, l_descr)

						-- the topic_id from the URL (as defined by the placeholder in the route)
					l_topic_id := req.path_parameter ("topic_id").string_representation

						-- update the task in the database
					db_handler_topic.update (l_topic,l_topic_id.to_natural)

						-- create a json object that as a "Message" property that states what happened (in the future, this should be a more meaningful messeage)
					prepare_response("Updated topic "+l_topic.title,200,res,true)
				else
						-- the user_id does not match
						-- we return an error stating that the user is not authorized to update the topic
					prepare_response("User is not topic owner",401,res,true)
				end

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to update the topic
				prepare_response("User not logged in.",401,res,true)
			end
		end

	remove_topic (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- remove a topic from the database
		local
			l_topic_id: STRING
			l_result: JSON_OBJECT
		do
			create l_result.make

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, the user is logged in and we can get the user id through the session data

					-- the topic_id from the URL (as defined by the placeholder in the route)
				l_topic_id := req.path_parameter ("topic_id").string_representation
					-- remove the topic
				db_handler_topic.remove (l_topic_id.to_natural)

					-- create a json object that as a "Message" property that states what happened (in the future, this should be a more meaningful messeage)
				prepare_response("Removed topic",200,res,true)

			else
					-- the request has no session cookie and thus the user is not logged in
					-- we return an error stating that the user is not authorized to remove the topic
				prepare_response("User not logged in.",401,res,true)
			end
		end


end

