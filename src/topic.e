note
	description: "A topic is a way for the project members to communicate. It is created by an user and it can have answers made by other project members."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	TOPIC

create
	make

feature -- Topic data

	project_id : NATURAL
		-- Project where the topic is in.

	task_id : NATURAL
		-- Task referenced by the topic.

	sprint_id : NATURAL
		-- Sprint referenced by the topic.

	user_id : NATURAL
		-- Creator of the topic.

	title : STRING
		-- Title.

	description : STRING
		-- Topic description.

	answered : BOOLEAN
		-- Used to differentiate answered topics in the views.

feature -- Creation

	make (a_project_id, a_task_id, a_sprint_id, a_user_id : NATURAL; a_title, a_descr : STRING)
		-- Default creation procedure
		require
			title_not_void: a_title /= Void
			descr_not_void: a_descr /= Void
		do
			project_id := a_project_id
			task_id := a_task_id
			sprint_id := a_sprint_id
			user_id := a_user_id
			title := a_title
			description := a_descr
			-- answered by default is false

		end

feature -- Operations

	set_title (a_title : STRING)
			-- Set a the topic title with `a_title'
		require
			title_not_void: a_title /= Void
		do
			title := a_title
		end

	set_description (a_descr : STRING)
			-- Set a the topic desctiption with `a_descr'
		require
			description_not_void: a_descr /= Void
		do
			description := a_descr
		end


end
