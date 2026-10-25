note
    description: "Automatic help fixtures with required values and an optional alias conflict."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class AUTOMATIC_HELP_COMMAND

inherit
    CLI_COMMAND

create
    make,
    make_custom

feature {NONE} -- Initialization

    make (a_conflict: BOOLEAN)
            -- Create a fixture that optionally reserves the short alias h.
        do
            has_alias_conflict := a_conflict
        end

    make_custom
            -- Create a fixture with an ordinary user-defined help flag.
        do
            has_custom_help := True
        end

feature -- Definition

    name: STRING_32 = ""
            -- Empty default command name.

    description: STRING_32 = "Automatic help fixture"
            -- Description shown in help.

    interface
            -- Declare required values and an explicitly assigned alias.
        do
            interface_count := interface_count + 1
            add_string_argument ("target", "Required target")
            add_integer_option ("count", "Required count")
            if has_custom_help then
                add_flag ("help", "Custom help")
            end
            add_flag ("verbose", "Verbose output")
            if has_alias_conflict then
                set_short_name ("verbose", 'h')
            else
                set_short_name ("verbose", 'v')
            end
        end

    interface_count: INTEGER
            -- Number of interface declarations.

feature -- Execution

    handle (a_values: CLI_COMMAND_INPUT)
            -- Report successful execution.
        do
            if has_custom_help and then a_values.boolean_parameter ("help") then
                io.put_string ("custom help handled%N")
            else
                io.put_string ("handled%N")
            end
        end

feature {NONE} -- Configuration

    has_custom_help: BOOLEAN

    has_alias_conflict: BOOLEAN

end
