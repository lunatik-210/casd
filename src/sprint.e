note
	description: "Sprint class thats represents sprints in CASD system"
	author: "$Rio Cuarto4 Team$"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	SPRINT

create
	make

feature -- Initialization

	make (new_status: STRING; new_duration: NATURAL; new_project_id: NATURAL)
			-- Creates a project with initial properties
		require
			not_empty (new_status)
		do
			status := new_status
			duration := new_duration
			project_id := new_project_id
		end

feature -- Sprint properties

	duration : NATURAL

	status : STRING

	project_id : NATURAL


feature -- Project seters

	set_project_duration(new_duration: NATURAL)
	do
		duration := new_duration
	end


feature -- Auxiliary routines

	not_empty(control: STRING) : BOOLEAN
			-- Validate if string isnt void or empty
	do
		if (not control.is_equal ("")) then
			Result := TRUE
		end
	end


end

