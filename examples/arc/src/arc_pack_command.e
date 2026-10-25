note
    description: "Archive-style pack commands that report parsed values only."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class ARC_PACK_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "pack"
            -- Command name used for selection.

    description: STRING_32 = "Describe archive creation"
            -- Description shown in generated help.

    interface
            -- Declare the command parameters.
        do
            add_string_argument ("archive", "Output archive path")
            add_optional_string_list_argument ("source", "Source paths", {ARRAY [STRING_32]} <<>>)
            add_optional_string_option ("format", "Explicit archive format", "")
            add_flag ("keep-root", "Retain the source directory name")
            add_optional_string_option ("password", "Archive password", "")
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
            -- Report the selected command and its parsed values.
        do
            io.put_string_32 ("command=pack%N")
            io.put_string_32 ({STRING_32} "archive=" + a_input.string_parameter ("archive") + "%N")
            io.put_string_32 ({STRING_32} "format=" + a_input.string_parameter ("format") + "%N")
            io.put_string_32 ({STRING_32} "keep-root=" + a_input.boolean_parameter ("keep-root").out + "%N")
            io.put_string_32 ({STRING_32} "password-set=" + (not a_input.string_parameter ("password").is_empty).out + "%N")
            io.put_string_32 ("sources:%N")
            across a_input.string_list_parameter ("source") as source loop
                io.put_string_32 ({STRING_32} "  " + source + "%N")
            end
        end

end
