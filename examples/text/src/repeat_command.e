note
    description: "Commands that print text a specified number of times."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    REPEAT_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "repeat"
            -- Command name used for selection.

    description: STRING_32 = "Print text a specified number of times"
            -- Description shown in generated help.

    interface
            -- Declare the command parameters.
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
            -- Print the text the requested number of times.
        local
            count, i: INTEGER
            text, line: STRING_32
        do
            count := a_input.integer_parameter ("count")
            if count < 0 then
                fail ("Count must be zero or greater.", Invalid_call)
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
