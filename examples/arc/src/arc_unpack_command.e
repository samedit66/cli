class
    ARC_UNPACK_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "unpack"

    description: STRING_32 = "Describe archive extraction"

    interface
        do
            add_string_argument ("archive", "Input archive path")
            add_optional_string_argument ("destination", "Destination directory", "")
            add_flag ("strip-root", "Remove one common root directory")
            add_optional_string_list_option ("entry", "Original entry path to extract", {ARRAY [STRING_32]} <<>>)
            add_optional_string_option ("password", "Archive password", "")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        do
            io.put_string_32 ("command=unpack%N")
            io.put_string_32 ({STRING_32} "archive=" + a_input.string_parameter ("archive") + "%N")
            io.put_string_32 ({STRING_32} "destination=" + a_input.string_parameter ("destination") + "%N")
            io.put_string_32 ({STRING_32} "strip-root=" + a_input.boolean_parameter ("strip-root").out + "%N")
            io.put_string_32 ({STRING_32} "password-set=" + (not a_input.string_parameter ("password").is_empty).out + "%N")
            io.put_string_32 ("entries:%N")
            across a_input.string_list_parameter ("entry") as entry loop
                io.put_string_32 ({STRING_32} "  " + entry + "%N")
            end
        end

end
