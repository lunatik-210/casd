note
	description: "[
		Tests for routines of class DB_HANDLER_TOPIC
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-12$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_TOPIC

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_by_id_existent_topic_test
			-- Test for routine find_by_id with existent topic id.
		local
			db_handler : DB_HANDLER_TOPIC
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			json_result := db_handler.find_by_id (1)

				-- correct attributes
			assert("Correct title ",json_result.item ("title").debug_output.is_equal("topic1"))
			assert("Correct description ", json_result.item ("description").debug_output.is_equal("topic1 descr"))
			assert("Correct answered value ", json_result.item("answered").debug_output.is_equal("0"))
			assert("Correct user_id", json_result.item ("user_id").debug_output.is_equal("1"))
			assert("Correct project_id", json_result.item ("project_id").debug_output.is_equal("1"))
			assert("Correct sprint_id", json_result.item ("sprint_id").debug_output.is_equal("1"))
			assert("Correct task_id", json_result.item ("task_id").debug_output.is_equal("1"))
		end

	find_by_id_nonexistent_topic_test
			-- Test for routine find_by_id with nonexistent topic id.
		local
			db_handler : DB_HANDLER_TOPIC
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.find_by_id (100)
			assert("Topic not found", json_result.is_empty)
		end

	add_topic_test
			-- Test for routine add
		local
			topic : TOPIC
			db_handler : DB_HANDLER_TOPIC
		do
			create topic.make (1, 1, 1, 1,"TITLE","DESCR")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(topic,topic.user_id,topic.project_id,topic.task_id,topic.sprint_id)
				-- assert when the topic was successfully added.
			assert ("Topic successfully added", not db_handler.db_insert_statement.has_error)
				-- remove the topic added for test
			db_handler.db.rollback
		end

	update_topic_test
			-- Test for routine update
		local
			topic : TOPIC
			db_handler : DB_HANDLER_TOPIC
		do
			create topic.make (1, 1, 1, 1,"TITLE","DESCR")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(topic,topic.user_id,topic.project_id,topic.task_id,topic.sprint_id)

			topic.set_title("new_title")
				-- update the topic in database
			db_handler.update(topic,db_handler.db_insert_statement.last_row_id.to_natural_32)
				-- assert when the topic was successfully updated.
			assert("Topic successfully updated", not db_handler.db_modify_statement.has_error)

				-- remove the topic added for test
			db_handler.db.rollback
		end

	remove_topic_test
		-- Test for routine remove
		local
			topic : TOPIC
			db_handler : DB_HANDLER_TOPIC
			json_result : JSON_OBJECT
		do
			create topic.make (1, 1, 1, 1, "TITLE", "DESCR")
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add(topic,topic.user_id,topic.project_id,topic.task_id,topic.sprint_id)
			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32)

				-- assert when the topic was successfully removed.
			json_result := db_handler.find_by_id (db_handler.db_insert_statement.last_row_id.to_natural_32)
			assert("Topic deleted", json_result.is_empty)

				-- remove the topic added for test
			db_handler.db.rollback
		end

end



