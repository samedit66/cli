class
    ARC_LIST_TREE_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "list tree"

    description: STRING_32 = "Describe tree listing using a two-word command"

    interface
        do
            add_string_argument ("archive", "Input archive path")
            add_optional_string_option ("password", "Archive password", "")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        do
            io.put_string_32 ("command=list tree%N")
            io.put_string_32 ({STRING_32} "archive=" + a_input.string_parameter ("archive") + "%N")
            io.put_string_32 ("tree=True%N")
            io.put_string_32 ({STRING_32} "password-set=" + (not a_input.string_parameter ("password").is_empty).out + "%N")
        end

end
