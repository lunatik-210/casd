note
	description: "[
		Tests for the Task model.
	]"
	author: "Rio Cuarto Team"
	date: "$2014-11-15$"
	revision: "$0.1$"
	testing: "type/manual"

class
	MAKE_AT_TASK

inherit
	EQA_TEST_SET

feature -- Test routines

	make_task_with_valid_values_test
			-- Test that creates a task with valid values.
		local
			task: TASK
		do
			create task.make (1, 1, 1, 10, "Title", "Description", "Bug", "Low", "Backlog")
			assert ("Title ok", task.title.is_equal("Title"))
			assert ("Description ok", task.description.is_equal("Description"))
			assert ("Type ok", task.type.is_equal("Bug"))
			assert ("Priority ok", task.priority.is_equal("Low"))
			assert ("Position ok", task.position.is_equal("Backlog"))
			assert ("Points ok", task.points=10)
			assert ("User id ok", task.user_id=1)
			assert ("Sprint id ok", task.sprint_id=1)
			assert ("Project id ok", task.project_id=1)
		end

	make_task_with_invalid_values_test
			-- Test that creates a task with some invalid value. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			task : TASK
		do
			if not second_time then
				ok := true
				create task.make (1, 1, 1, 10, "Title", "Descr", "Not a bug", "High", "Backlog")
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

	make_sub_task_with_valid_values_test
			-- Test that creates a sub task with valid values.
		local
			task: TASK
		do
			create task.make_sub_task (1, 1, 1, 1, 10, "Title", "Description", "Bug", "Low", "Backlog")
			assert ("Title ok", task.title.is_equal("Title"))
			assert ("Description ok", task.description.is_equal("Description"))
			assert ("Type ok", task.type.is_equal("Bug"))
			assert ("Priority ok", task.priority.is_equal("Low"))
			assert ("Position ok", task.position.is_equal("Backlog"))
			assert ("Points ok", task.points=10)
			assert ("Super task id ok", task.super_task_id=1)
			assert ("User id ok", task.user_id=1)
			assert ("Sprint id ok", task.sprint_id=1)
			assert ("Project id ok", task.project_id=1)
		end

	make_sub_task_with_invalid_values_test
			-- Test that creates a sub task with some invalid value. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			task : TASK
		do
			if not second_time then
				ok := true
				create task.make_sub_task (1, 1, 1, 1, 10, "Title", "Descr", "Not a bug", "High", "Backlog")
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

end


