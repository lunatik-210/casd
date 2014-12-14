note
	description: "A Task is what a project member must do. It has an associated sprint (and of course project)."
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	TASK

create
	make, make_sub_task

feature -- Task data

	sprint_id : NATURAL
		-- Sprint where the task belongs.

	super_task_id : NATURAL
		-- If the task is a sub-task, it has a super-task associated.

	user_id : NATURAL
		-- Accountable of the task.

	project_id : NATURAL
		-- Project where the task belongs.

	points : NATURAL
		-- Task number of points

	title : STRING
		-- Title.

	description : STRING
		-- Task description.

	type : STRING
		-- Type can be: Bug or Feature.

	priority : STRING
		-- Priority can be: Low, High or Normal.

	position : STRING
		-- Position can be: Backlog, Process, Done, Testing or Canceled.



feature -- Creation

	make (a_sprint_id, a_user_id, a_project_id, some_points: NATURAL; a_title, a_descr, a_type, a_priority, a_pos : STRING)
		-- Default creation procedure
		require
			title_not_void: a_title /= Void
			type_not_void: a_type /= Void
			priority_not_void: a_priority /= Void
			position_not_void: a_pos /= Void
		do
			if (a_descr = Void) then
					-- put a blank description if no description is present.
				description := " "
			else
				description := a_descr
			end
			sprint_id := a_sprint_id
			user_id := a_user_id
			project_id := a_project_id
			points := some_points
			title := a_title
			type := a_type
			priority := a_priority
			position := a_pos
			-- a super task has itself as a super, but in the object creation both values are zero
			-- the database handler is going to insert this values correctly

		end

	make_sub_task (a_sprint_id, a_user_id, a_super_task_id, a_project_id, some_points: NATURAL; a_title, a_descr, a_type, a_priority, a_pos : STRING)
		-- Creation procedure for a sub task
		require
			title_not_void: a_title /= Void
			type_not_void: a_type /= Void
			priority_not_void: a_priority /= Void
			position_not_void: a_pos /= Void
		do
			if (a_descr = Void) then
					-- put a blank description if no description is present.
				description := " "
			else
				description := a_descr
			end
			sprint_id := a_sprint_id
			user_id := a_user_id
			project_id := a_project_id
			points := some_points
			title := a_title
			type := a_type
			priority := a_priority
			position := a_pos
			super_task_id := a_super_task_id -- Super task of this subtask

		end

feature -- Operations

	set_title (a_title : STRING)
			-- Set a the task title with `a_title'
		require
			title_not_void: a_title /= Void
		do
			title := a_title
		end

	set_description (a_descr : STRING)
			-- Set a the task desctiption with `a_descr'
		require
			description_not_void: a_descr /= Void
		do
			description := a_descr
		end

	set_points (some_points : NATURAL)
			-- Set a the task points with `some_points'
		do
			points := some_points
		end

	set_type (a_type : STRING)
			-- Set a the task type with `a_type'
		require
			type_not_void: a_type /= Void
		do
			type := a_type
		end

	set_priority (a_priority : STRING)
			-- Set a the task type with `a_priority'
		require
			piority_not_void: a_priority /= Void
		do
			priority := a_priority
		end

	set_position (a_pos : STRING)
			-- Set a the task type with `a_pos'
		require
			position_not_void: a_pos /= Void
		do
			position := a_pos
		end


invariant -- Invariant for enumerated types
	correct_type: (type.is_equal("Bug")) or (type.is_equal("Feature"))
	correct_priority: (priority.is_equal("Low")) or (priority.is_equal("Normal")) or (priority.is_equal("High"))
	correct_position: (position.is_equal("Backlog")) or (position.is_equal("Process")) or (position.is_equal("Done")) or (position.is_equal("Testing")) or (position.is_equal("Canceled"))

end
