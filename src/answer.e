note
	description: "This class represents an answer of the application "
	author: "Rio Cuarto4 Team"
	date: "$2014-11-06$"
	revision: "$0.01$"

class
	ANSWER

create
	make

feature -- Initialization

	make(new_description : STRING; answered_topic_id : NATURAL; answerer_user_id : NATURAL)
			-- Creates an answer with a given description, user_id and topic_id.
		require
			valid_description: (new_description /= Void) and (new_description.count>0)
		do
			description := new_description
			topic_id := answered_topic_id
			user_id := answerer_user_id
		end

feature -- Answer data

	description : STRING

	topic_id : NATURAL

	user_id : NATURAL

feature -- Operations

	set_description (new_description : STRING)
			-- update the answer description.
		require
			valid_description: (new_description/=Void) and (new_description.count>0)
		do
			description := new_description
		end

end
