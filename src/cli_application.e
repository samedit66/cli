class
    CLI_APPLICATION

inherit
    CLI_FAILURE
        export
            {NONE} fail
        end

create
    make

feature {NONE} -- Initialization

    make (a_name, a_description: STRING_32)
        require
            non_empty_name: not a_name.is_empty
        local
            l_help: CLI_HELP_COMMAND
        do
            name := a_name.twin
            description := a_description.twin
            create commands.make (Default_capacity)
            create l_help.make (Current)
            add_command (l_help)
        end

feature -- Definition

    name: STRING_32

    description: STRING_32

    add_command (a_command: CLI_COMMAND)
            -- Register a command and declare its interface.
        require
            non_empty_name: not a_command.name.is_empty
            unique_name: not has_command (a_command.name)
        do
            a_command.interface
            commands.extend (a_command)
        ensure
            registered: has_command (a_command.name)
        end

    has_command (a_name: STRING_32): BOOLEAN
        do
            Result := across commands as c some c.name.same_string (a_name) end
        end

feature -- Help

    help: STRING_32
            -- Fresh application help, in command registration order.
        do
            Result := name + " - " + description + "%N%NUsage:%N  " + name +
                " <command> [arguments and options]%N%NCommands:%N"
            across commands as c loop
                Result.append ({STRING_32} "  " + c.name + "  " + c.description + "%N")
            end
            Result.append ({STRING_32} "%NRun '" + name + " help <command>' for command help.%N")
        end

    command_help (a_name: STRING_32): STRING_32
        require
            known_command: has_command (a_name)
        do
            create Result.make_empty
            across commands as c loop
                if c.name.same_string (a_name) then
                    Result := c.help (name + " " + c.name)
                end
            end
        end

    show_help (a_command_name: STRING_32)
            -- Print general help for an empty name, or help for a command.
        do
            if a_command_name.is_empty then
                io.put_string_32 (help)
            elseif has_command (a_command_name) then
                io.put_string_32 (command_help (a_command_name))
            else
                report_unknown_command (a_command_name)
            end
        end

feature -- Execution

    run
            -- Execute using process arguments, excluding the executable name.
            -- Invalid calls terminate the process with {CLI_COMMAND}.Invalid_call.
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
            -- Select and execute a command. Tokens exclude the executable name.
            -- Invalid calls terminate the process with {CLI_COMMAND}.Invalid_call.
        local
            l_command: detachable CLI_COMMAND
            l_tokens: ARRAYED_LIST [STRING_32]
            l_parser: CLI_PARSER
            i: INTEGER
        do
            if a_tokens.lower > a_tokens.upper then
                show_help ("")
            else
                across commands as c loop
                    if c.name.same_string (a_tokens [a_tokens.lower]) then
                        l_command := c
                    end
                end

                if attached l_command as c then
                    create l_tokens.make (a_tokens.upper - a_tokens.lower)
                    from i := a_tokens.lower + 1 until i > a_tokens.upper loop
                        l_tokens.extend (a_tokens [i])
                        i := i + 1
                    end
                    create l_parser.make (c.parameters)
                    l_parser.parse (l_tokens)
                    if l_parser.is_successful then
                        c.handle (l_parser.values)
                    else
                        report_error (l_parser.error_message + "%NRun '" + name + " help " + c.name + "' for usage.")
                    end
                else
                    report_unknown_command (a_tokens [a_tokens.lower])
                end
            end
        end

feature {NONE} -- Implementation

    commands: ARRAYED_LIST [CLI_COMMAND]

    report_unknown_command (a_name: STRING_32)
        do
            report_error ({STRING_32} "Unknown command: " + a_name + "%NRun '" + name + " help' to see available commands.")
        end

    report_error (a_message: STRING_32)
        do
            fail (a_message, {CLI_COMMAND}.Invalid_call)
        ensure
            never_returns: False
        end

feature {NONE} -- Capacity

    Default_capacity: INTEGER = 4
            -- Initial capacity of internal collections.

end
