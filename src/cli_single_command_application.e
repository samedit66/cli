class
    CLI_SINGLE_COMMAND_APPLICATION
        -- Runs one command directly. Adds a help flag to its parameters only
        -- when no parameter named "help" exists; existing help belongs to the command.

create
    make

feature {NONE} -- Initialization

    make (a_command: CLI_COMMAND)
        do
            command := a_command
            name := a_command.name.twin
            description := a_command.description.twin
            command.interface
            if not across command.parameters as p some p.name.same_string_general ("help") end then
                command.add_flag ("help", "Show this help")
                has_builtin_help := True
            end
        end

feature -- Definition

    name: STRING_32

    description: STRING_32

feature -- Help

    help: STRING_32
            -- Fresh help derived from the command parameters.
        do
            Result := command.help (name)
        end

feature -- Execution

    has_error: BOOLEAN
            -- Did parsing fail? Reset at the beginning of each run.

    run
            -- Execute using process arguments, excluding the executable name.
        local
            l_arguments: ARGUMENTS_32
            l_tokens: ARRAYED_LIST [STRING_32]
            i: INTEGER
        do
            create l_arguments
            create l_tokens.make (l_arguments.argument_count)
            from i := 1 until i > l_arguments.argument_count loop
                l_tokens.extend (l_arguments.argument (i))
                i := i + 1
            end
            run_with_tokens (l_tokens)
        end

    run_with_tokens (a_tokens: READABLE_INDEXABLE [STRING_32])
            -- Parse tokens directly, handling an application-added help flag first.
        local
            l_parser: CLI_PARSER
        do
            has_error := False
            create l_parser.make (command.parameters)
            l_parser.parse_tokens (a_tokens)
            if not l_parser.has_error then
                if has_builtin_help and then l_parser.recognized_values.boolean_parameter ("help") then
                    io.put_string_32 (help)
                else
                    l_parser.validate_required
                    if l_parser.is_successful then
                        command.handle (l_parser.values)
                    end
                end
            end
            if l_parser.has_error then
                has_error := True
                io.error.put_string_32 (l_parser.error_message + "%NRun '" + name + " --help' for usage.%N")
            end
        end

feature {NONE} -- Implementation

    has_builtin_help: BOOLEAN
            -- Did this application add and take responsibility for the help flag?

    command: CLI_COMMAND

end
