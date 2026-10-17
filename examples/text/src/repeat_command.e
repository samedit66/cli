class
    REPEAT_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "repeat"

    description: STRING_32 = "Print text a specified number of times"

    interface
        do
            add_string_argument ("text", "Text to repeat")
            add_integer_option ("count", "Number of repetitions (zero or greater)")
            set_short_name ("count", 'n')
            add_optional_string_option ("prefix", "Prefix for each line", "")
            set_short_name ("prefix", 'p')
            add_flag ("upper", "Convert the text to uppercase")
            set_short_name ("upper", 'u')
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        local
            count, i: INTEGER
            text, line: STRING_32
            exceptions: EXCEPTIONS
        do
            count := a_input.integer_parameter ("count")
            if count < 0 then
                io.error.put_string_32 ("Count must be zero or greater.%N")
                create exceptions
                exceptions.die (2)
            else
                text := a_input.string_parameter ("text")
                if a_input.boolean_parameter ("upper") then
                    text.to_upper
                end
                line := a_input.string_parameter ("prefix") + text + "%N"
                from i := 0 until i = count loop
                    io.put_string_32 (line)
                    i := i + 1
                end
            end
        end

end
