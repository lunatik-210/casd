note
	description: "[
		Tests for routines of class Answer
	]"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	AT_ANSWER

inherit
	EQA_TEST_SET

feature -- Test routines

	new_answer_with_valid_values_test
			-- Test that creates an answer with valid values.
		local
			answer : ANSWER
		do
			create answer.make("Some answer",1,1)
			assert ("Description ok", answer.description.is_equal("Some answer"))
			assert ("User id ok", answer.user_id=1)
			assert ("Topic id ok", answer.topic_id=1)
		end

	new_answer_with_invalid_description_test
			-- Test that creates an answer with an empty description which is invalid. Should raise an exception.
		local
			ok, second_time : BOOLEAN
			answer : ANSWER
		do
			if not second_time then
				ok := true
				create answer.make ("",1,1)
				ok := false
			end
			assert("routine failed, as expected.",ok)
		rescue
			second_time := true
			if ok then
				retry
			end
		end

	set_description_test
			-- Test for routine set_description
		local
			answer : ANSWER
		do
			create answer.make ("Some answer",1,1)
			answer.set_description ("Edited answer")
			assert("Correct description",answer.description.is_equal ("Edited answer"))
		end
end


