note
	description: "This class manages the database operations that concerns answers."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-10$"
	revision: "$0.01$"

class
	DB_HANDLER_ANSWER

inherit
	CASD_DB

create
	make

feature -- Data access

	find_by_id (answer_id : NATURAL) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents an answer that corresponds to the given id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Answers WHERE id="+ answer_id.out +";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 4, Result))
		ensure
			correct_id: Result.item ("id").debug_output.is_equal(answer_id.out)
		end

	find_by_topic_id (topic_id : NATURAL) : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents an answer
			-- related with a topic with id = topic_id
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Answers WHERE topic_id="+ topic_id.out+";",db)
			db_query_statement.execute (agent rows_to_json_array(?, 4, Result))
		end

	add (answer : ANSWER)
			-- adds a new answer
		require
			valid_answer: (answer/=Void)
		do
			create db_insert_statement.make ("INSERT INTO Answers(description,topic_id,user_id) "+
											"VALUES ('" + answer.description + "','"+ answer.topic_id.out +"',"+
											"'"+ answer.user_id.out +"');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new answer")
			end
		end

	update (answer_id : NATURAL;answer: ANSWER)
			-- updates an answer
		require
			valid_answer: (answer/=Void)
		do
			create db_modify_statement.make ("UPDATE Answers SET description = '"+ answer.description +"',"+
															  "topic_id = '"+ answer.topic_id.out +"',"+
															  "user_id = '"+ answer.user_id.out +"'"+
															  "WHERE id="+ answer_id.out +";" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating an answer")
			end
		end

	remove (answer_id: NATURAL)
			-- removes the answer with the given id
		do
			create db_modify_statement.make ("DELETE FROM Answers WHERE id=" + answer_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting an answer")
			end
		end

end
