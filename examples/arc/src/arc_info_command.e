note
    description: "Archive-style info commands that report parsed values only."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    ARC_INFO_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "info"
            -- Command name used for selection.

    description: STRING_32 = "Describe archive inspection"
            -- Description shown in generated help.

    interface
            -- Declare the command parameters.
        do
            add_string_argument ("archive", "Input archive path")
            add_optional_string_option ("password", "Archive password", "")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
            -- Report the selected command and its parsed values.
        do
            io.put_string_32 ("command=info%N")
            io.put_string_32 ({STRING_32} "archive=" + a_input.string_parameter ("archive") + "%N")
            io.put_string_32 ({STRING_32} "password-set=" + (not a_input.string_parameter ("password").is_empty).out + "%N")
        end

end
