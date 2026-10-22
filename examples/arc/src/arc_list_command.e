class
    ARC_LIST_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "list"

    description: STRING_32 = "Describe archive listing"

    interface
        do
            add_string_argument ("archive", "Input archive path")
            add_flag ("tree", "List entries as a tree")
            add_optional_string_option ("password", "Archive password", "")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        do
            io.put_string_32 ("command=list%N")
            io.put_string_32 ({STRING_32} "archive=" + a_input.string_parameter ("archive") + "%N")
            io.put_string_32 ({STRING_32} "tree=" + a_input.boolean_parameter ("tree").out + "%N")
            io.put_string_32 ({STRING_32} "password-set=" + (not a_input.string_parameter ("password").is_empty).out + "%N")
        end

end
