note
    description: "Archive-style root commands that report parsed values only."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    ARC_ROOT_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = ""
            -- Command name used for selection.

    description: STRING_32 = "Recognize root flags"
            -- Description shown in generated help.

    interface
            -- Declare the command parameters.
        do
            add_flag ("help", "Request application help")
            add_flag ("version", "Request version information")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
            -- Report flags as ordinary parsed values.
        do
            io.put_string_32 ("command=<root>%N")
            io.put_string_32 ({STRING_32} "help=" + a_input.boolean_parameter ("help").out + "%N")
            io.put_string_32 ({STRING_32} "version=" + a_input.boolean_parameter ("version").out + "%N")
        end

end
