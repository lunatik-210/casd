note
	description: "[
		Tests for routines of class DB_HANDLER_ANSWER
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-12$"
	revision: "$0.01$"

class
	AT_DB_HANDLER_ANSWER

inherit
	DB_HANDLER_TEST

feature -- Test routines

	find_by_id_existent_answer_test
			-- Test for routine find_by_id with existent answer id.
		local
			db_handler : DB_HANDLER_ANSWER
			json_result : JSON_OBJECT
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			json_result := db_handler.find_by_id (1)

				-- correct attributes
			assert ("Correct description", json_result.item ("description").debug_output.is_equal("answer1"))
			assert ("Correct topic_id", json_result.item ("topic_id").debug_output.is_equal("3"))
			assert ("Correct user_id", json_result.item ("user_id").debug_output.is_equal("3"))
		end

	find_by_id_nonexistent_answer_test
			-- Test for routine find_by_id with nonexistent answer id.
		local
			db_handler : DB_HANDLER_ANSWER
			json_result : JSON_OBJECT
			ok, second_time : BOOLEAN
		do
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")
			if not second_time then
				ok := True
				json_result := db_handler.find_by_id (100)
				ok := False
			end
			assert ("routine failed, as expected", ok )
		rescue
			second_time := True
			if ok then
				retry
			end
		end

	add_answer_test
			-- Test for routine add
		local
			answer : ANSWER
			db_handler : DB_HANDLER_ANSWER
		do
			create answer.make ("Another answer", 1, 1)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (answer)
				-- assert the answer was successfully added.
			assert ("Answer successfully added", not db_handler.db_insert_statement.has_error )
				-- remove the answer added for test.
			db_handler.db.rollback
		end

	update_answer_test
			-- Test for routine update
		local
			answer : ANSWER
			db_handler : DB_HANDLER_ANSWER
		do
			create answer.make ("Another answer", 1, 1)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (answer)

			answer.set_description ("Edit description")
				-- update the answer in the database
			db_handler.update (db_handler.db_insert_statement.last_row_id.to_natural_32, answer)
				-- assert the answer was successfully updated.
			assert ("Answer successfully updated", not db_handler.db_insert_statement.has_error )
				-- remove the answer added for test.
			db_handler.db.rollback
		end

	remove_answer_test
			-- Test for routine remove.
		local
			answer : ANSWER
			db_handler : DB_HANDLER_ANSWER
		do
			create answer.make ("Another answer", 1, 1)
			create db_handler.make(".." + Operating_environment.directory_separator.out + "casd_test.db")

			db_handler.db.begin_transaction (true)
			db_handler.add (answer)
			db_handler.remove (db_handler.db_insert_statement.last_row_id.to_natural_32)
				-- assert if the answer was successfully removed.
			assert ("Answer successfully removed", not db_handler.db_modify_statement.has_error)
			db_handler.db.rollback
		end

end


