note
	description: "Tests for routine make at class Project"
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	MAKE_AT_PROJECT

inherit
	EQA_TEST_SET

feature -- Test routines

	make_with_correct_values
			-- Creation test with correct values
		local
			project: PROJECT
		do
			create project.make ("name","status", "description", 1, 1)
			assert ("Correct name", project.name.is_equal ("name"))
			assert ("Correct status", project.status.is_equal ("status"))
			assert ("Correct description", project.description.is_equal ("description"))
			assert ("Correct mpps", project.max_points_per_sprint.is_equal (1))
			assert ("Correct user_id", project.user_id.is_equal (1))
		end


	creation_negative_test_with_empty_name
			-- Creation test with empty name
		local
  			ok, second_time: BOOLEAN
  			project: PROJECT
		do
    		if not second_time then
          		ok := True
          		create project.make ("", "new_status", "new_description", 1, 1) -- Must throw an exception
          		ok := False
    		end
    		assert ("The rutine has to fail", ok)
		rescue
     		second_time := True
     		if ok then   -- ok = true means that the rutine failed
           		retry
    		end
		end

	creation_negative_test_with_empty_description
			-- Creation test with empty description
		local
  			ok, second_time: BOOLEAN
  			project: PROJECT
		do
    		if not second_time then
          		ok := True
          		create project.make ("new_name", "new_status", "", 1, 1) -- Must throw an exception
          		ok := False
    		end
    		assert ("The rutine has to fail", ok)
		rescue
     		second_time := True
     		if ok then   -- ok = true means that the rutine failed
           		retry
    		end
		end


end
