note
	description: "[
		Test for the topic model.
	]"
	author: "Rio Cuarto Team"
	date: "$2014-11-15$"
	revision: "$0.1$"
	testing: "type/manual"

class
	MAKE_AT_TOPIC

inherit
	EQA_TEST_SET

feature -- Test routines

	make_topic_with_valid_values_test
			-- Test that creates a topic with valid values.
		local
			topic: TOPIC
		do
			create topic.make (1, 1, 1, 1, "Title", "Description")
			assert ("Title ok", topic.title.is_equal("Title"))
			assert ("Description ok", topic.description.is_equal("Description"))
			assert ("User id ok", topic.user_id=1)
			assert ("Sprint id ok", topic.sprint_id=1)
			assert ("Task id ok", topic.task_id=1)
			assert ("Project id ok", topic.project_id=1)
		end

	make_topic_with_invalid_values_test
			-- Test that creates topic with some invalid value. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			topic : TOPIC
		do
			if not second_time then
				ok := true
				create topic.make (1, 1, 1, 1, "title", Void)
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

	set_title_with_valid_values_test
			-- Test that changes an existing topic title with a new (valid) one.
		local
			topic: TOPIC
		do
			create topic.make (1, 1, 1, 1, "title", "descr")
			topic.set_title ("new title")
			assert("New title ok", topic.title.is_equal ("new title"))
		end

	set_title_with_invalid_values_test
			-- Test that changes an existing topic title with a new (invalid) one. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			topic : TOPIC
		do
			if not second_time then
				ok := true
				create topic.make (1, 1, 1, 1, "title", "descr")
				topic.set_title (Void)
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

	set_description_with_valid_values_test
			-- Test that changes an existing topic description with a new (valid) one.
		local
			topic: TOPIC
		do
			create topic.make (1, 1, 1, 1, "title", "descr")
			topic.set_description ("new descr")
			assert("New description ok", topic.description.is_equal ("new descr"))
		end

	set_description_with_invalid_values_test
			-- Test that changes an existing topic description with a new (invalid) one. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			topic : TOPIC
		do
			if not second_time then
				ok := true
				create topic.make (1, 1, 1, 1, "title", "descr")
				topic.set_description (Void)
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


