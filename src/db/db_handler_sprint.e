note
	description: "This class manages the database operations that concerns sprints."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-11$"
	revision: "$0.01$"

class
	DB_HANDLER_SPRINT

inherit
	CASD_DB

create
	make

feature -- Data access

	find_all : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a sprint
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Sprints;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 4, Result))

		end

	find_by_id_and_project_id (sprint_id : INTEGER; project_id: INTEGER) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents a sprint that
			-- corresponds to the given sprint_id and project_id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Sprints WHERE id="+ sprint_id.out +" AND project_id="+project_id.out+";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 4, Result))
		end

	find_by_project_id (project_id : NATURAL) : JSON_ARRAY
			-- return a JSON_ARRAY where each element is a JSON_OBJECT that represents a Sprint
			-- thats correspond to the given project_id
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Sprints WHERE project_id="+ project_id.out+";",db)
			db_query_statement.execute (agent rows_to_json_array(?, 4, Result))
		end

	add (sprint: SPRINT)
			-- adds a new sprint
		do
			create db_insert_statement.make ("INSERT INTO Sprints(id,status,duration,project_id) "+
											"VALUES ('-1','"+ sprint.status +"','"+ sprint.duration.out +"','"+
											sprint.project_id.out+"');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new sprint")
			end
		end

	update (sprint_id : NATURAL; sprint: SPRINT)
			-- update a sprint
		do
			create db_modify_statement.make ("UPDATE Sprints SET status = '"+ sprint.status +"',"+
															  "duration = '"+ sprint.duration.out +"'"+
															  "WHERE (id="+ sprint_id.out +") and (project_id = '"+ sprint.project_id.out +"');" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating a sprint")
			end
		end

	remove (sprint_id: NATURAL; project_id: NATURAL)
			-- removes the sprint with the given id and project id
		do
			create db_modify_statement.make ("DELETE FROM Sprints WHERE id=" + sprint_id.out + " AND project_id=" + project_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a sprint")
					-- TODO: we probably want to return something if there's an error
			end
		end

feature -- Data access for reports

	total_sprints_by_status_and_project_id (status : STRING;project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of sprints which status is 'status' related to a given project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_sprints FROM sprints WHERE status='"+ status +"' AND project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end

	total_sprints_by_project_id (project_id: NATURAL) : JSON_OBJECT
			-- returns the quantity of sprints of a given project
		do
			create Result.make
			create db_query_statement.make("SELECT COUNT(*) AS total_sprints FROM sprints WHERE project_id="+project_id.out+";",db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end


end
