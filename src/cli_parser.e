class
    CLI_PARSER

create
    make

feature {NONE} -- Initialization

    make (a_parameters: ITERABLE [CLI_PARAMETER])
            -- Use definitions that remain unchanged during parsing.
        do
            create parameters.make (Default_capacity)
            create positional_parameters.make (Default_capacity)

            across a_parameters as p loop
                parameters.extend (p)
                if p.kind = p.Argument_kind then
                    positional_parameters.extend (p)
                end
            end

            create parsed_values.make
            create seen_names.make (Default_capacity)
            create last_error.make_empty
        end

feature -- Parsing

    parse (a_tokens: READABLE_INDEXABLE [STRING_32])
            -- Parse once, stopping at the first input error.
            -- Tokens exclude the program and subcommand names.
        require
            not_parsed: not is_parsed
        local
            i, l_position: INTEGER
            l_options_finished: BOOLEAN
            l_token: STRING_32
            l_parameter: detachable CLI_PARAMETER
        do
            initialize_defaults

            from
                i := a_tokens.lower
                l_position := 1
            until
                i > a_tokens.upper or has_error
            loop
                l_token := a_tokens [i]
                if not l_options_finished and then l_token.same_string_general ("--") then
                    l_options_finished := True
                else
                    l_parameter := Void
                    if not l_options_finished then
                        l_parameter := named_parameter (l_token)
                    end
                    if attached l_parameter as p then
                        if seen_names.has (p.name) and then not p.is_multiple then
                            fail ({STRING_32} "Repeated parameter: " + p.name)
                        elseif p.kind = p.Flag_kind then
                            parsed_values.put_boolean (p.name, True)
                            seen_names.force (True, p.name.twin)
                        elseif i = a_tokens.upper then
                            fail ({STRING_32} "Missing value for option: " + l_token)
                        else
                            i := i + 1
                            store_value (p, a_tokens [i])
                        end
                    elseif not l_options_finished and then is_option_token (l_token) and then
                        not is_negative_integer_argument (l_token, l_position)
                    then
                        fail ({STRING_32} "Unknown option: " + l_token)
                    elseif l_position > positional_parameters.count then
                        fail ({STRING_32} "Unexpected argument: " + l_token)
                    else
                        store_value (positional_parameters [l_position], l_token)
                        if not positional_parameters [l_position].is_multiple then
                            l_position := l_position + 1
                        end
                    end
                end
                i := i + 1
            end

            across parameters as p loop
                if not has_error and then not p.is_optional and then not seen_names.has (p.name) then
                    fail ({STRING_32} "Missing required parameter: " + p.name)
                end
            end

            is_parsed := True
        ensure
            parsed: is_parsed
            outcome: is_successful xor has_error
        end

feature -- Status report

    is_parsed: BOOLEAN

    is_successful: BOOLEAN
        do
            Result := is_parsed and then not has_error
        end

    has_error: BOOLEAN
        do
            Result := not last_error.is_empty
        end

feature -- Result

    values: CLI_COMMAND_INPUT
            -- Complete values; no partial result is exposed.
        require
            successful: is_successful
        do
            Result := parsed_values
        end

    error_message: STRING_32
        require
            failed: has_error
        do
            Result := last_error.twin
        end

feature {NONE} -- Definitions and state

    parameters: ARRAYED_LIST [CLI_PARAMETER]

    positional_parameters: ARRAYED_LIST [CLI_PARAMETER]

    parsed_values: CLI_COMMAND_INPUT

    seen_names: HASH_TABLE [BOOLEAN, STRING_32]

    last_error: STRING_32

feature {NONE} -- Implementation

    initialize_defaults
        do
            across parameters as p loop
                if p.kind = p.Flag_kind then
                    parsed_values.put_boolean (p.name, False)
                elseif p.is_multiple then
                    if p.value_type = p.Integer_type then
                        parsed_values.put_integer_list (p.name, p.integer_list_default)
                    else
                        parsed_values.put_string_list (p.name, p.string_list_default)
                    end
                elseif p.is_optional then
                    if p.value_type = p.Integer_type then
                        parsed_values.put_integer (p.name, p.integer_default)
                    else
                        parsed_values.put_string (p.name, p.string_default)
                    end
                end
            end
        end

    named_parameter (a_token: STRING_32): detachable CLI_PARAMETER
        do
            across parameters as p loop
                if p.kind /= p.Argument_kind then
                    if a_token.count > 2 and then a_token.starts_with ("--") and then
                        p.name.same_string (a_token.substring (3, a_token.count))
                    then
                        Result := p
                    elseif a_token.count = 2 and then a_token [1] = '-' and then
                        p.has_short_name and then p.short_name = a_token [2]
                    then
                        Result := p
                    end
                end
            end
        end

    is_option_token (a_token: STRING_32): BOOLEAN
        do
            Result := a_token.count > 1 and then a_token [1] = '-'
        end

    is_negative_integer_argument (a_token: STRING_32; a_position: INTEGER): BOOLEAN
            -- An integer operand may start with a minus sign.
        do
            Result := a_position <= positional_parameters.count and then
                positional_parameters [a_position].value_type = positional_parameters [a_position].Integer_type and then
                a_token.count > 1 and then a_token [1] = '-' and then a_token [2].is_digit
        end

    store_value (a_parameter: CLI_PARAMETER; a_token: STRING_32)
        do
            if a_parameter.value_type = a_parameter.Integer_type then
                if a_token.is_integer_32 then
                    if a_parameter.is_multiple then
                        if seen_names.has (a_parameter.name) then
                            parsed_values.append_integer (a_parameter.name, a_token.to_integer_32)
                        else
                            parsed_values.put_integer_list (a_parameter.name, {ARRAY [INTEGER]} <<a_token.to_integer_32>>)
                        end
                    else
                        parsed_values.put_integer (a_parameter.name, a_token.to_integer_32)
                    end
                else
                    fail ({STRING_32} "Invalid integer for " + a_parameter.name + ": " + a_token)
                end
            else
                if a_parameter.is_multiple then
                    if seen_names.has (a_parameter.name) then
                        parsed_values.append_string (a_parameter.name, a_token)
                    else
                        parsed_values.put_string_list (a_parameter.name, {ARRAY [STRING_32]} <<a_token>>)
                    end
                else
                    parsed_values.put_string (a_parameter.name, a_token)
                end
            end
            if not has_error then
                seen_names.force (True, a_parameter.name.twin)
            end
        end

    fail (a_message: STRING_32)
        do
            last_error := a_message.twin
        end

feature {NONE} -- Capacity

    Default_capacity: INTEGER = 4
            -- Initial capacity of internal collections.

end
