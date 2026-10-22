class
    CLI_STRING_ROUTINES

feature -- Splitting

    split (a_value: READABLE_STRING_32; a_separator: CHARACTER_32): ARRAYED_LIST [STRING_32]
            -- Parts separated by `a_separator`, preserving empty parts and whitespace.
            -- Quotes and escape characters have no special meaning.
        local
            l_part: STRING_32
            i: INTEGER
        do
            create Result.make (1)
            create l_part.make_empty
            from i := 1 until i > a_value.count loop
                if a_value [i] = a_separator then
                    Result.extend (l_part)
                    create l_part.make_empty
                else
                    l_part.append_character (a_value [i])
                end
                i := i + 1
            end
            Result.extend (l_part)
        ensure
            at_least_one_part: not Result.is_empty
        end

end
