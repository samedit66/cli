note
    description: "Choice validation and string comparison modes for command-line definitions."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class CLI_CHOICE_ROUTINES

feature -- Comparison modes

    Case_sensitive: BOOLEAN = True
            -- Compare string choices with exact casing.

    Case_insensitive: BOOLEAN = False
            -- Compare string choices without regard to casing.

feature -- Validation

    are_valid_integer_choices (a_choices: ITERABLE [INTEGER]): BOOLEAN
            -- Is the collection nonempty and free of duplicate values?
        local
            l_seen: ARRAYED_LIST [INTEGER]
        do
            create l_seen.make (4)
            Result := True
            across a_choices as value loop
                if l_seen.has (value) then
                    Result := False
                end
                l_seen.extend (value)
            end
            Result := Result and not l_seen.is_empty
        end

    are_valid_string_choices (a_choices: ITERABLE [READABLE_STRING_32]; a_case_sensitive: BOOLEAN): BOOLEAN
            -- Is the collection nonempty and unambiguous under the chosen comparison?
        local
            l_seen: ARRAYED_LIST [READABLE_STRING_32]
        do
            create l_seen.make (4)
            Result := True
            across a_choices as value loop
                if has_string_choice (l_seen, value, a_case_sensitive) then
                    Result := False
                end
                l_seen.extend (value)
            end
            Result := Result and not l_seen.is_empty
        end

    has_integer_choice (a_choices: ITERABLE [INTEGER]; a_value: INTEGER): BOOLEAN
            -- Does the collection contain `a_value`?
        do
            Result := across a_choices as value some value = a_value end
        end

    has_string_choice (a_choices: ITERABLE [READABLE_STRING_32]; a_value: READABLE_STRING_32; a_case_sensitive: BOOLEAN): BOOLEAN
            -- Does the collection contain `a_value` under the chosen comparison?
        do
            Result := across a_choices as value some
                matching_choice_strings (value, a_value, a_case_sensitive) end
        end

feature {NONE} -- Comparison

    matching_choice_strings (a_left, a_right: READABLE_STRING_32; a_case_sensitive: BOOLEAN): BOOLEAN
            -- Do both strings match using the selected comparison?
        do
            if a_case_sensitive then
                Result := a_left.same_string (a_right)
            else
                Result := a_left.is_case_insensitive_equal (a_right)
            end
        end

end
