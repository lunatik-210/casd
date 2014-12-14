note
	description: "This class manages the database operations that concerns projects."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-11$"
	revision: "$0.01$"

class
	DB_HANDLER_PROJECT

inherit
	CASD_DB

create
	make

feature -- Data access

	find_all : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents a project
		do
			create Result.make_array
			create db_query_statement.make ("SELECT * FROM Projects;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 7, Result))

		end

	find_by_user_loged(user_id: INTEGER) : JSON_ARRAY
			-- returns a JSON_ARRAY where each element is a JSON_OBJECT that represents
			-- a project where the user is collaborator or owner	
		do
			create Result.make_array
			create db_query_statement.make ("select id,name,status,description,max_points_per_sprint,p.user_id as 'user_id' from projects p where p.user_id="
										+user_id.out+" union select id,name,status,description,max_points_per_sprint,p.user_id as 'user_id' from projects p,"
										 +"collaborators c where c.user_id="+user_id.out+" and c.project_id = p.id;", db)
			db_query_statement.execute (agent rows_to_json_array (?, 6, Result))

		end

	find_by_id (project_id : INTEGER) : JSON_OBJECT
			-- returns a JSON_OBJECT that represents a project that corresponds to the given id
		do
			create Result.make
			create db_query_statement.make("SELECT * FROM Projects WHERE id="+ project_id.out +";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 7, Result))
		end

	find_collabs_by_project_id (project_id : INTEGER) : JSON_ARRAY
			-- returns a JSON_JSON_ARRAY where each element is a JSON_OBJECT that
			-- represents a collaborator to the given project
		do
			create Result.make_array
			create db_query_statement.make("SELECT * FROM Collaborators WHERE project_id="+ project_id.out +";" ,db)
			db_query_statement.execute (agent rows_to_json_array (?, 2, Result))
		end

	find_owner(project_id: INTEGER) : JSON_OBJECT
			-- Return the user_id of the owner of the given project
		do
			create Result.make
			create db_query_statement.make("SELECT user_id FROM Projects WHERE id="+project_id.out+";" ,db)
			db_query_statement.execute (agent row_to_json_object (?, 1, Result))
		end


	add (project: PROJECT)
			-- adds a new project
		do
			create db_insert_statement.make ("INSERT INTO Projects(name,status,description,max_points_per_sprint,number_of_sprints,user_id) "+
											"VALUES ('" + project.name + "','"+ project.status +"','"+ project.description +
											"','" + project.max_points_per_sprint.out +"','"+ project.number_of_sprints.out +
											"','" + project.user_id.out +"');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new project")
			end
		end


	add_collaborator (user_id, project_id: NATURAL)
			-- adds a new collaborator
		do
			create db_insert_statement.make ("INSERT OR REPLACE INTO Collaborators(user_id,project_id) "+
											"VALUES ('" + user_id.out + "','"+ project_id.out +"');", db);
			db_insert_statement.execute
			if db_insert_statement.has_error then
				print("Error while inserting a new collaborator")
			end
		end

	update (project_id : NATURAL; project: PROJECT)
			-- update a project
		do
			create db_modify_statement.make ("UPDATE Projects SET name = '"+ project.name +"',"+
															  "status = '"+ project.status +"',"+
															  "description = '"+ project.description +"',"+
															  "max_points_per_sprint = '"+ project.max_points_per_sprint.out +"'"+
															  "WHERE id="+ project_id.out +";" , db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while updating a project")
			end
		end

	remove (project_id: NATURAL)
			-- removes the project with the given id
		do
			create db_modify_statement.make ("DELETE FROM Projects WHERE id=" + project_id.out + ";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a Project")
					-- TODO: we probably want to return something if there's an error
			end
		end

	remove_collaborator (user_id, project_id: NATURAL)
			-- removes the collaborator with the given user_id and project_id
		do
			create db_modify_statement.make ("DELETE FROM Collaborators WHERE user_id=" + user_id.out + " AND project_id="+project_id.out+";", db)
			db_modify_statement.execute
			if db_modify_statement.has_error then
				print("Error while deleting a Collaborator")
					-- TODO: we probably want to return something if there's an error
			end
		end

end
