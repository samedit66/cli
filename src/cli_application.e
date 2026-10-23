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
        do
            name := a_name.twin
            description := a_description.twin
            create commands.make (Default_capacity)
        end

feature -- Definition

    name: STRING_32

    description: STRING_32

    add_command (a_command: CLI_COMMAND)
            -- Register a command and declare its interface.
        require
            valid_name: is_valid_command_name (a_command.name)
            unique_name: not has_command (a_command.name)
        do
            a_command.interface
            commands.extend (a_command)
        ensure
            registered: has_command (a_command.name)
        end

    is_valid_command_name (a_name: STRING_32): BOOLEAN
            -- Is this an empty default name or a canonical sequence of non-option words?
        do
            Result := not a_name.starts_with (" ") and then
                not a_name.ends_with (" ") and then not a_name.has_substring ("  ") and then
                not a_name.has ('%T') and then not a_name.has ('%N') and then
                not a_name.has ('%R') and then
                across a_name.split (' ') as word all not word.starts_with ("-") end
        end

    has_command (a_name: STRING_32): BOOLEAN
        do
            Result := across commands as c some c.name.same_string (a_name) end
        end

feature -- Help

    help: STRING_32
            -- Fresh application help, in command registration order.
        do
            Result := name + " - " + description + "%N%NUsage:%N  " + name
            if has_command ("") then
                Result.append (" [command]")
            else
                Result.append (" <command>")
            end
            Result.append (" [arguments and options]%N%NCommands:%N")
            across commands as c loop
                if c.name.is_empty then
                    Result.append ({STRING_32} "  (default)  " + c.description + "%N")
                else
                    Result.append ({STRING_32} "  " + c.name + "  " + c.description + "%N")
                end
            end
        end

    command_help (a_name: STRING_32): STRING_32
        require
            known_command: has_command (a_name)
        do
            create Result.make_empty
            across commands as c loop
                if c.name.same_string (a_name) then
                    if c.name.is_empty then
                        Result := c.help (name)
                    else
                        Result := c.help (name + " " + c.name)
                    end
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
            l_match: detachable TUPLE [command: CLI_COMMAND; consumed_count: INTEGER]
            l_tokens: ARRAYED_LIST [STRING_32]
            l_parser: CLI_PARSER
            i: INTEGER
        do
            l_match := selected_command (a_tokens)
            if attached l_match as match then
                create l_tokens.make (a_tokens.upper - a_tokens.lower + 1 - match.consumed_count)
                from i := a_tokens.lower + match.consumed_count until i > a_tokens.upper loop
                    l_tokens.extend (a_tokens [i])
                    i := i + 1
                end
                if l_tokens.count = 1 and then l_tokens.first.same_string ("--help") and then
                    across match.command.parameters as p all not p.name.same_string ("help") end
                then
                    -- A standalone help request bypasses parsing unless explicitly overridden.
                    show_help (match.command.name)
                else
                    create l_parser.make (match.command.parameters)
                    l_parser.parse (l_tokens)
                    if l_parser.is_successful then
                        match.command.handle (l_parser.values)
                    else
                        report_error (l_parser.error_message)
                    end
                end
            elseif a_tokens.upper = a_tokens.lower and then a_tokens [a_tokens.lower].same_string ("--help") then
                show_help ("")
            elseif a_tokens.lower > a_tokens.upper then
                report_error ("Missing command.")
            else
                report_unknown_command (a_tokens [a_tokens.lower])
            end
        end

feature {NONE} -- Implementation

    selected_command (a_tokens: READABLE_INDEXABLE [STRING_32]): detachable TUPLE [command: CLI_COMMAND; consumed_count: INTEGER]
            -- Command with the longest complete word prefix, including an empty default.
        local
            l_words: LIST [STRING_32]
            l_count, i: INTEGER
            l_matches: BOOLEAN
        do
            across commands as c loop
                l_count := 0
                l_matches := True
                if not c.name.is_empty then
                    l_words := c.name.split (' ')
                    l_count := l_words.count
                    l_matches := l_count <= a_tokens.upper - a_tokens.lower + 1
                    from i := 1 until i > l_count or not l_matches loop
                        l_matches := l_words [i].same_string (a_tokens [a_tokens.lower + i - 1])
                        i := i + 1
                    end
                end
                if l_matches and then (not attached Result as best or else l_count > best.consumed_count) then
                    Result := [c, l_count]
                end
            end
        end

    commands: ARRAYED_LIST [CLI_COMMAND]

    report_unknown_command (a_name: STRING_32)
        do
            report_error ({STRING_32} "Unknown command: " + a_name)
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
