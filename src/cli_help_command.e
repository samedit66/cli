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
            add_optional_string_argument ("command", "Command to describe", "")
        end

feature -- Execution

    handle (a_values: CLI_COMMAND_INPUT)
        do
            application.show_help (a_values.string_parameter ("command"))
        end

feature {NONE} -- Implementation

    application: CLI_APPLICATION

end
