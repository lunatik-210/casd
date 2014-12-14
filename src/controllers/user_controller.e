note
	description: "Handlers for everything that concerns users."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-08$"
	revision: "$0.1$"

class
	USER_CONTROLLER

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
			create db_handler_user.make(a_path_to_db_file)
			create bcrypt.make
			session_manager := a_session_manager
		end


feature {NONE} -- Private attributes

	db_handler_user : DB_HANDLER_USER

	session_manager : WSF_SESSION_MANAGER

	bcrypt: BCRYPT
		-- Encryption

feature -- Handlers

	get_users (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a reponse that contains a json array with all users if some user is logged in.
		local
			l_result_payload: STRING
		do
			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

				l_result_payload := db_handler_user.find_all.representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get the users.
				prepare_response("User is not logged in",401,res,true)
			end
		end

	get_user (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json object with a user with given id if some user is logged in.
		local
			l_result_payload: STRING
			l_user_id : STRING
		do
			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

					-- the user_id from the URL
				l_user_id := req.path_parameter ("user_id").string_representation

				l_result_payload := db_handler_user.find_by_id (l_user_id.to_natural).representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to get a user.
				prepare_response("User is not logged in",401,res,true)
			end
		end

	get_logged_user (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- sends a response that contains a json object with the user logged data.
		local
			l_result_payload: STRING
			l_user_session_id : STRING
			json_result : JSON_OBJECT
		do
			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

					-- get the id of the user logged in from the session store
				l_user_session_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

				json_result := db_handler_user.find_by_id(l_user_session_id.to_natural)
				json_result.remove ("password")

				l_result_payload := json_result.representation

				prepare_response(l_result_payload,200,res,false)
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error.
				prepare_response("User is not logged in",401,res,true)
			end
		end

	add_user (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- adds a new user; the user data are expected to be part of the request's payload
		local
			l_payload : STRING
			l_user_name, l_email, l_password : STRING
			l_hashed_password: STRING
			l_user : USER
			parser: JSON_PARSER
		do
				-- create emtpy string object
			create l_payload.make_empty

				-- read the payload from the request and store it in the string
			req.read_input_data_into (l_payload)

				-- now parse the json object that we got as part of the payload
			create parser.make_parser (l_payload)

				-- if the parsing was successful and we have a json object, we fetch the user data
			if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each user attribute.
				if attached {JSON_STRING} j_object.item ("user_name") as user_name then
					l_user_name := user_name.unescaped_string_8
				end
				if attached {JSON_STRING} j_object.item ("email") as email then
					l_email := email.unescaped_string_8
				end
				if attached {JSON_STRING} j_object.item ("password") as password then
					l_password := password.unescaped_string_8
				end

			end

			if db_handler_user.has_user (l_email).has_user then
					-- Already exists a user with email l_email, thus we return an error stating that
					-- the user is already registered.
				prepare_response("Already exists an account with this email",401,res,true)

			else
					-- The email is available

					-- here we hash the password with salt for database storing
				l_hashed_password := bcrypt.hashed_password (l_password, bcrypt.new_salt(4))

				create l_user.make(l_user_name,l_email,l_hashed_password)
					-- create the user in the database
				db_handler_user.add (l_user)

					-- prepare the response
				prepare_response("Added user " + l_user.username,200,res,true)

			end
		end

	update_user (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- updates an existent user
		local
			l_payload: STRING
			l_user_session_id, l_user_id: STRING
			l_user_name, l_email, l_password : STRING
			l_hashed_password: STRING
			l_user : USER
			parser : JSON_PARSER
		do
				-- create empty object
			create l_payload.make_empty

			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

					-- get the id of the user logged in from the session store
				l_user_session_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- the user_id from the URL (as defined by the placeholder in the route)
				l_user_id := req.path_parameter ("user_id").string_representation

				if (l_user_session_id.is_equal(l_user_id)) then
						-- the user logged is the same as the user that is being updated.

						-- read the payload from the request and store it in the string
					req.read_input_data_into (l_payload)

						-- now parse the json object that we got as part of the payload
					create parser.make_parser (l_payload)

						-- if the parsing was successful and we have a json object, we fetch the user properties
					if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

						-- we have to convert the json string into an eiffel string for each user attribute.
						if attached {JSON_STRING} j_object.item ("user_name") as user_name then
							l_user_name := user_name.unescaped_string_8
						end
						if attached {JSON_STRING} j_object.item ("email") as email then
							l_email := email.unescaped_string_8
						end
						if attached {JSON_STRING} j_object.item ("password") as password then
							l_password := password.unescaped_string_8
						end

					end

						-- here we hash the password with salt for database storing
					l_hashed_password := bcrypt.hashed_password (l_password, bcrypt.new_salt(4))

						-- create the user
					create l_user.make (l_user_name, l_email, l_hashed_password)

						-- update the user in the database
					db_handler_user.update (l_user_id.to_natural,l_user)

						-- prepare the response
					prepare_response("Updated user " + l_user.username,200,res,true)

				else
						-- the user logged is not the same as the user that is being updated.
						-- we return an error stating that the user is not authorized to update another user.
					prepare_response("The user logged is unauthorized for update another user.",401,res,true)
				end
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to update another user.
				prepare_response("User is not logged in",401,res,true)
			end
		end

	remove_user (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- removes a user from the database
		local
			l_user_session_id,l_user_id: STRING
			l_session: WSF_COOKIE_SESSION
		do
			if req_has_cookie (req, "_casd_session_") then
					-- the request has a cookie of name "_casd_session_"
					-- thus, a user is logged in.

					-- get the id of the user logged in from the session store
				l_user_session_id := get_session_from_req (req, "_casd_session_").at ("user_id").out

					-- the user_id from the URL (as defined by the placeholder in the route)
				l_user_id := req.path_parameter ("user_id").string_representation

				if (l_user_session_id.is_equal(l_user_id)) then
						-- the user logged is the same as the user that is being removed.

						-- remove the user
					db_handler_user.remove (l_user_id.to_natural)
						-- prepare the reponse
					prepare_response("Removed item",200,res,true)
						-- destroy the session
					create l_session.make (req, "_casd_session_", session_manager)
					l_session.destroy

				else
						-- the user logged is not the same as the user that is being removed.
						-- we return an error stating that the user is not authorized to remove another user.
					prepare_response("The user logged is unauthorized for remove another user.",401,res,true)
				end
			else
					-- the request has no session cookie and thus no user is logged in
					-- we return an error stating that the user is not authorized to remove another user.
				prepare_response("User is not logged in.",401,res,true)
			end
		end

	login (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- login a user if the email and password provided with the request are correct
			-- "login" is done via attaching a session cookie to the response. The browser will
			-- then send this session cookie on all subsequent request, allowing us to lookup the
			-- session data for that user based on the cookie

		local
			l_payload, l_email, l_password: STRING
			parser: JSON_PARSER
				-- if true the email and password match
			l_user_data: TUPLE [has_user: BOOLEAN; user_id: STRING; is_active: STRING; email: STRING; hashed_pass: STRING]
				-- a session
			l_session: WSF_COOKIE_SESSION
		do
				-- create emtpy string object
			create l_payload.make_empty

				-- read the payload from the request and store it in the string
			req.read_input_data_into (l_payload)

				-- now parse the json object that we got as part of the payload
			create parser.make_parser (l_payload)

				-- if the parsing was successful and we have a json object, we fetch the properties
				-- in this case the email and password
			if attached {JSON_OBJECT} parser.parse as j_object and parser.is_parsed then

					-- we have to convert the json string into an eiffel string for each propertie.
				if attached {JSON_STRING} j_object.item ("email") as s then
					l_email := s.unescaped_string_8
				end
				if attached {JSON_STRING} j_object.item ("password") as s then
					l_password := s.unescaped_string_8
				end

			end

				-- check if the database has this particular email
			l_user_data := db_handler_user.has_user(l_email)

			if (l_user_data.has_user and l_user_data.is_active.is_equal("1")) then
					-- yes, the email was correct
					-- so next, we check for the password
				if (bcrypt.is_valid_password (l_password, l_user_data.hashed_pass)) then
						-- the password is correct
						-- so next, we create a session

						-- create the session; choose a name for the cookie that we'll send back
					create l_session.make_new ("_casd_session_", session_manager)

						-- add all the data we need to the session (format here is [value, key] pairs)
						-- we store the email and the key "email"
					l_session.remember (l_user_data.email, "email")
						-- we store the user id and use the key "user_id"
					l_session.remember (l_user_data.user_id, "user_id")

						-- commit the data; this will trigger the session_manager to acutally store the data to disk (in the session folder _WFS_SESSIONS_)
					l_session.commit

						-- apply the session cookie to the response; we use path "/" which makes the session cookie available on path of our app
					l_session.apply (req, res, "/")

						-- prepare the response
					prepare_response("User logged in",200,res,true)

				else
						-- the password was wrong
						-- so we don't create a session
						-- but return an error message
					prepare_response("Password incorrect",401,res,true)
				end

			else
					-- the email was wrong
					-- so we don't create a session
					-- but return an error message
				prepare_response("Email incorrect",401,res,true)
			end
		end



	logout (req: WSF_REQUEST; res: WSF_RESPONSE)
			-- logout a user
			-- that means we destroy the user's session (if one exists)
		local
			l_session: WSF_COOKIE_SESSION
		do
				-- we load the session if it exists (if no session exists, we're acutally creating a new one. But that's okay because we'll immediately destroy it)
			create l_session.make (req, "_casd_session_", session_manager)
			l_session.destroy
				-- prepare the response
			prepare_response("User logged out",200,res,true)
		end

end
