note
	description: "Provides helper functions to set the HTTP header of a response that returns json."
	author: "hce"

class
	HEADER_JSON_HELPER


feature

	set_json_header_ok (res: WSF_RESPONSE; a_content_length: INTEGER)
			-- sets the header of the given repsonse to status code 200
			-- sets the content type to json
			-- sets the content lenght according to `a_content_lenght'
		do
			res.set_status_code (200)
			res.header.put_content_type_application_json
			res.header.put_content_length (a_content_length)
		end

	set_json_header (res: WSF_RESPONSE; a_status_code: INTEGER; a_content_length: INTEGER)
			-- sets the header of the given to status code `a_status_code'
			-- sets the content type to json
			-- sets the content lenght according to `a_content_lenght'
		do
			res.set_status_code (a_status_code)
			res.header.put_content_type_application_json
			res.header.put_content_length (a_content_length)
		end

	prepare_response (content : STRING; a_status_code : INTEGER; res : WSF_RESPONSE ; is_message : BOOLEAN)
			-- Prepare the response `resp' with a json_object that contains a `message' `and a_status_code'
		local
			json_result : JSON_OBJECT
		do
			res.set_status_code (a_status_code)
			res.header.put_content_type_application_json
			create json_result.make
			if is_message then
				json_result.put_string ( content , create {JSON_STRING}.make_json ("Message"))
				res.header.put_content_length (json_result.representation.count)
				res.put_string (json_result.representation)
			else
				res.header.put_content_length (content.count)
				res.put_string(content)
			end
		end

end
