class
    FAKETAR_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "faketar"

    description: STRING_32 = "Report parsed parameters only; no archive or file operations.%NShort options: flags combine (-cvz). The first value option takes the entire%Nremainder of the group, stripping one leading '='; otherwise it takes the next%Ntoken. Thus -cvzfarchive.tar sets c, v, z and file=archive.tar; -fcvz sets file=cvz."

    interface
        do
            add_flag ("create", "Report the create flag")
            set_short_name ("create", 'c')
            add_flag ("extract", "Report the extract flag")
            set_short_name ("extract", 'x')
            add_flag ("list", "Report the list flag")
            set_short_name ("list", 't')
            add_flag ("verbose", "Report the verbose flag")
            set_short_name ("verbose", 'v')
            add_flag ("gzip", "Report the gzip flag")
            set_short_name ("gzip", 'z')
            add_flag ("bzip2", "Report the bzip2 flag")
            set_short_name ("bzip2", 'j')
            add_flag ("preserve", "Report the preserve flag")
            set_short_name ("preserve", 'p')
            add_optional_string_option ("file", "Archive name to report", "")
            set_short_name ("file", 'f')
            add_optional_string_option ("directory", "Directory to report", ".")
            set_short_name ("directory", 'C')
            add_optional_integer_option ("blocking-factor", "Integer to report", 20)
            set_short_name ("blocking-factor", 'b')
            add_optional_string_list_option ("exclude", "Patterns to report", {ARRAY [STRING_32]} <<>>)
            set_short_name ("exclude", 'X')
            add_optional_integer_list_option ("checkpoint", "Checkpoint numbers to report", {ARRAY [INTEGER]} <<>>)
            set_short_name ("checkpoint", 'K')
            add_optional_string_list_argument ("paths", "Paths to report", {ARRAY [STRING_32]} <<>>)
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
        do
            io.put_string_32 ({STRING_32} "create=" + a_input.boolean_parameter ("create").out + "%N")
            io.put_string_32 ({STRING_32} "extract=" + a_input.boolean_parameter ("extract").out + "%N")
            io.put_string_32 ({STRING_32} "list=" + a_input.boolean_parameter ("list").out + "%N")
            io.put_string_32 ({STRING_32} "verbose=" + a_input.boolean_parameter ("verbose").out + "%N")
            io.put_string_32 ({STRING_32} "gzip=" + a_input.boolean_parameter ("gzip").out + "%N")
            io.put_string_32 ({STRING_32} "bzip2=" + a_input.boolean_parameter ("bzip2").out + "%N")
            io.put_string_32 ({STRING_32} "preserve=" + a_input.boolean_parameter ("preserve").out + "%N")
            io.put_string_32 ({STRING_32} "file=" + a_input.string_parameter ("file") + "%N")
            io.put_string_32 ({STRING_32} "directory=" + a_input.string_parameter ("directory") + "%N")
            io.put_string_32 ({STRING_32} "blocking-factor=" + a_input.integer_parameter ("blocking-factor").out + "%N")
            io.put_string_32 ({STRING_32} "paths:%N")
            across a_input.string_list_parameter ("paths") as path loop
                io.put_string_32 ({STRING_32} "  " + path + "%N")
            end
            io.put_string_32 ({STRING_32} "exclude:%N")
            across a_input.string_list_parameter ("exclude") as pattern loop
                io.put_string_32 ({STRING_32} "  " + pattern + "%N")
            end
            io.put_string_32 ({STRING_32} "checkpoint:%N")
            across a_input.integer_list_parameter ("checkpoint") as number loop
                io.put_string_32 ({STRING_32} "  " + number.out + "%N")
            end
        end

end
