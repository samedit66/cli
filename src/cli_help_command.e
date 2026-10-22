class
    CLI_HELP_COMMAND

inherit
    CLI_COMMAND

create
    make

feature {NONE} -- Initialization

    make (a_application: CLI_APPLICATION)
        do
            application := a_application
        end

feature -- Definition

    name: STRING_32 = "help"

    description: STRING_32 = "Show application or command help"

feature -- Interface definition

    interface
        do
            add_optional_string_list_argument ("command", "Command words to describe", {ARRAY [STRING_32]} <<>>)
        end

feature -- Execution

    handle (a_values: CLI_COMMAND_INPUT)
        local
            l_name: STRING_32
        do
            create l_name.make_empty
            across a_values.string_list_parameter ("command") as word loop
                if not l_name.is_empty then
                    l_name.append_character (' ')
                end
                l_name.append (word)
            end
            application.show_help (l_name)
        end

feature {NONE} -- Implementation

    application: CLI_APPLICATION

end
