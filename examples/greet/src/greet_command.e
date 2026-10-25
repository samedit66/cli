note
    description: "Greeting commands with an optional name and greeting."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class GREET_COMMAND

inherit
    CLI_COMMAND

feature -- Metadata

    name: STRING_32 = ""
            -- Command name used for selection.

    description: STRING_32 = "Greet someone"
            -- Description shown in generated help.

feature -- Command interface

    interface
            -- Declare the command parameters.
        do
            add_optional_string_argument ("name", "Person to greet", "world")
            add_optional_string_option ("prefix", "Greeting prefix", "Hello")
            set_short_name ("prefix", 'p')
            add_flag ("yell", "Print the greeting in uppercase")
            set_short_name ("yell", 'y')
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
            -- Print a greeting using the parsed values.
        local
            l_greeting: STRING_32
        do
            l_greeting := a_input.string_parameter ("prefix") + ", " +
                a_input.string_parameter ("name") + "!"
            if a_input.boolean_parameter ("yell") then
                l_greeting.to_upper
            end
            io.put_string_32 (l_greeting + "%N")
        end

end
