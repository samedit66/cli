class
    ROUTING_COMMAND

inherit
    CLI_COMMAND

create
    make,
    make_required

feature {NONE} -- Initialization

    make (a_name: STRING_32)
        do
            name := a_name.twin
            requires_target := name.same_string ("remote required")
        end

    make_required (a_name: STRING_32)
            -- Use the required-parameter interface regardless of the command name.
        do
            make (a_name)
            requires_target := True
        end

feature -- Definition

    name: STRING_32

    description: STRING_32 = "Report the selected command and its values"

    interface
        do
            add_flag ("verbose", "Verbose flag")
            set_short_name ("verbose", 'v')
            add_flag ("help", "Ordinary flag without a privileged path")
            set_short_name ("help", 'h')
            if name.is_empty then
                add_flag ("root-only", "An option belonging only to the default command")
            end
            if requires_target then
                add_string_argument ("target", "Required target")
                add_integer_option ("count", "Required count")
            else
                add_optional_string_list_argument ("arguments", "Remaining values", {ARRAY [STRING_32]} <<>>)
                add_optional_integer_option ("count", "Count", 7)
            end
            set_short_name ("count", 'n')
            add_optional_string_list_option ("tag", "Tags", {ARRAY [STRING_32]} <<"default">>)
            set_short_name ("tag", 't')
            add_optional_integer_list_option ("checkpoint", "Checkpoints", {ARRAY [INTEGER]} <<8, 9>>)
            set_short_name ("checkpoint", 'K')
        end

feature -- Execution

    handle (a_values: CLI_COMMAND_INPUT)
        do
            io.put_string_32 ({STRING_32} "command=" + name + "%N")
            io.put_string_32 ({STRING_32} "verbose=" + a_values.boolean_parameter ("verbose").out + "%N")
            io.put_string_32 ({STRING_32} "help=" + a_values.boolean_parameter ("help").out + "%N")
            io.put_string_32 ({STRING_32} "count=" + a_values.integer_parameter ("count").out + "%N")
            if a_values.has_parameter ("root-only") then
                io.put_string_32 ({STRING_32} "root-only=" + a_values.boolean_parameter ("root-only").out + "%N")
            end
            io.put_string_32 ("arguments:%N")
            if a_values.has_parameter ("target") then
                io.put_string_32 ({STRING_32} "  " + a_values.string_parameter ("target") + "%N")
            else
                across a_values.string_list_parameter ("arguments") as value loop
                    io.put_string_32 ({STRING_32} "  " + value + "%N")
                end
            end
            io.put_string_32 ("tags:%N")
            across a_values.string_list_parameter ("tag") as value loop
                io.put_string_32 ({STRING_32} "  " + value + "%N")
            end
            io.put_string_32 ("checkpoints:%N")
            across a_values.integer_list_parameter ("checkpoint") as value loop
                io.put_string_32 ({STRING_32} "  " + value.out + "%N")
            end
        end

feature {NONE} -- Configuration

    requires_target: BOOLEAN

end
