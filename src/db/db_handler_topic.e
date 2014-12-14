note
	description: "This class manages the database operations that concerns topics."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-08$"
	revision: "$0.1$"

class
	DB_HANDLER_TOPIC

inherit
	CASD_DB

create
	make

feature -- Data access

	find_all : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a topic
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Topics;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 8, Result))

		end

	find_by_id (a_topic_id : NATURAL) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents a topic that corresponds to the given id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Topics WHERE id="+ a_topic_id.out +";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 8, Result))
		ensure
			correct_id: (Result.item("id").debug_output.is_equal(a_topic_id.out))
		end

	add(a_topic: TOPIC; a_user_id, a_project_id, a_task_id, a_sprint_id: NATURAL)
			-- Adds a topic to the corresponding project, with the desired creator
		require
			topic_not_void: (a_topic /= Void)
		do
			create db_insert_statement.make ("INSERT INTO Topics(title,description,answered,user_id,project_id,task_id,sprint_id) VALUES ('" + a_topic.title + "','" + a_topic.description + "','" + a_topic.answered.to_integer.out + "','" + a_user_id.out + "','" + a_project_id.out + "','" + a_task_id.out + "','" + a_sprint_id.out + "');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new topic")
			end
		end

	update (topic: TOPIC; topic_id : NATURAL)
			-- Update a topic
		require
			topic_not_void: (topic /= Void)
		do
			create db_modify_statement.make ("UPDATE Topics SET title = '"+ topic.title +"',"+
															  "description = '"+ topic.description +"',"+
															  "answered = '"+ topic.answered.to_integer.out +"'"+
															  "WHERE id="+ topic_id.out +";" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating a topic")
			end
		end

	remove (topic_id: NATURAL)
			-- removes the topic with the given id
		do
			create db_modify_statement.make ("DELETE FROM Topics WHERE id=" + topic_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a Topic")
					-- TODO: we probably want to return something if there's an error
			end
		end

end
