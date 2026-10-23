note
    description: "Single-use parsers for command-line parameter definitions and tokens."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    CLI_PARSER

create
    make

feature {NONE} -- Initialization

    make (a_parameters: ITERABLE [CLI_PARAMETER])
            -- Retain definitions for one parse.
            -- Definitions must remain unchanged until parsing finishes.
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
            create last_error.make_empty
        end

feature -- Parsing

    parse (a_tokens: READABLE_INDEXABLE [STRING_32])
            -- Consume tokens, check completeness, and supply absent defaults.
            -- Read tokens without retaining or changing the input.
        require
            not_parsed: not is_parsed
        local
            i, j, l_position, l_state, l_equals_position: INTEGER
            l_token, l_option_token, l_short_token: STRING_32
            l_pending_option: detachable CLI_PARAMETER
        do
            from
                i := a_tokens.lower
                l_position := 1
                l_state := Reading_parameters
            until
                i > a_tokens.upper or has_error
            loop
                l_token := a_tokens [i]
                inspect l_state
                when Expecting_option_value then
                    check attached l_pending_option as p then
                        if l_token.count > 1 and then l_token [1] = '-' then
                            -- An option-like token cannot fill a pending value.
                            fail ({STRING_32} "Missing value for option: --" + p.name)
                        else
                            store_value (p, l_token)
                        end
                    end
                    l_pending_option := Void
                    -- Return to parameter recognition for the next token.
                    l_state := Reading_parameters

                when Reading_parameters, Reading_positionals then
                    if l_state = Reading_parameters and then l_token.same_string ("--") then
                        -- All following tokens are positional values.
                        l_state := Reading_positionals

                    elseif l_state = Reading_parameters and then l_token.starts_with ("--") then
                        -- Split only the first '='; its suffix is a literal value.
                        l_equals_position := l_token.index_of ('=', 3)
                        if l_equals_position > 0 then
                            l_option_token := l_token.substring (1, l_equals_position - 1)
                        else
                            l_option_token := l_token
                        end
                        if attached lookup_option (l_option_token) as p then
                            if p.kind = p.Flag_kind then
                                if l_equals_position > 0 then
                                    fail ({STRING_32} "Flag does not accept a value: " + l_option_token)
                                else
                                    store_value (p, Void)
                                end
                            elseif l_equals_position > 0 then
                                store_value (p, l_token.substring (l_equals_position + 1, l_token.count))
                            else
                                l_pending_option := p
                                -- The next iteration consumes the option's value.
                                l_state := Expecting_option_value
                            end
                        else
                            fail ({STRING_32} "Unknown option: " + l_token)
                        end

                    elseif l_state = Reading_parameters and then
                        l_token.count > 1 and then l_token [1] = '-'
                    then
                        from j := 2 until j > l_token.count or has_error loop
                            l_short_token := {STRING_32} "-" + l_token.substring (j, j)
                            if attached lookup_option (l_short_token) as p then
                                if p.kind = p.Flag_kind then
                                    if j < l_token.count and then l_token [j + 1] = '=' then
                                        fail ({STRING_32} "Flag does not accept a value: " + l_short_token)
                                    else
                                        store_value (p, Void)
                                    end
                                elseif j < l_token.count and then l_token [j + 1] = '=' then
                                    -- The suffix is literal and ends the short group.
                                    store_value (p, l_token.substring (j + 2, l_token.count))
                                    j := l_token.count
                                elseif j < l_token.count then
                                    fail ({STRING_32} "Option with a value must end the group: " + l_short_token)
                                else
                                    l_pending_option := p
                                    -- A value option must end its group.
                                    l_state := Expecting_option_value
                                end
                            else
                                fail ({STRING_32} "Unknown option: " + l_short_token)
                            end
                            j := j + 1
                        end

                    elseif l_position > positional_parameters.count then
                        -- Keep the current token and its tail unconsumed on error.
                        fail ({STRING_32} "Unexpected argument: " + l_token)
                    else
                        store_value (positional_parameters [l_position], l_token)
                        if not has_error and then not positional_parameters [l_position].is_multiple then
                            -- Advance the positional queue; a list stays at its head.
                            l_position := l_position + 1
                        end
                    end
                end

                if not has_error then
                    -- The only advancement through input tokens.
                    i := i + 1
                end
            end

            if not has_error then
                if attached l_pending_option as p then
                    fail ({STRING_32} "Missing value for option: --" + p.name)
                else
                    complete_values
                end
            end
            is_parsed := True
        ensure
            parsed: is_parsed
            outcome: is_successful xor has_error
        end

feature -- Status report

    is_parsed: BOOLEAN
            -- Has parsing finished?

    is_successful: BOOLEAN
            -- Has parsing finished without an error?
        do
            Result := is_parsed and then not has_error
        end

    has_error: BOOLEAN
            -- Has parsing failed?
        do
            Result := not last_error.is_empty
        end

feature -- Result

    values: CLI_COMMAND_INPUT
            -- Complete values after successful parsing.
        require
            successful: is_successful
        do
            Result := parsed_values
        end

    error_message: STRING_32
            -- Copy of the diagnostic from a failed parse.
        require
            failed: has_error
        do
            Result := last_error.twin
        end

feature {NONE} -- Input and result

    parameters: ARRAYED_LIST [CLI_PARAMETER]

    positional_parameters: ARRAYED_LIST [CLI_PARAMETER]
            -- Declaration order; the parse-local position is the queue head.

    parsed_values: CLI_COMMAND_INPUT
            -- Contains only explicit values until completion supplies defaults.

    last_error: STRING_32

feature {NONE} -- Implementation

    lookup_option (a_spelling: STRING_32): detachable CLI_PARAMETER
            -- Definition matching an exact long name or one-letter alias.
        do
            across parameters as p loop
                if p.kind /= p.Argument_kind then
                    if a_spelling.count > 2 and then a_spelling.starts_with ("--") and then
                        p.name.same_string (a_spelling.substring (3, a_spelling.count))
                    then
                        Result := p
                    elseif a_spelling.count = 2 and then a_spelling [1] = '-' and then
                        p.has_short_name and then p.short_name = a_spelling [2]
                    then
                        Result := p
                    end
                end
            end
        end

    store_value (a_parameter: CLI_PARAMETER; a_token: detachable STRING_32)
            -- Store one explicit occurrence; flags have no value token.
        require
            value_for_non_flag: (a_parameter.kind = a_parameter.Flag_kind) = (a_token = Void)
        do
            if parsed_values.has_parameter (a_parameter.name) and then not a_parameter.is_multiple then
                fail ({STRING_32} "Repeated parameter: " + a_parameter.name)
            elseif a_parameter.kind = a_parameter.Flag_kind then
                parsed_values.put_boolean (a_parameter.name, True)
            elseif attached a_token as l_token then
                if a_parameter.value_type = a_parameter.Integer_type then
                    if not l_token.is_integer_32 then
                        fail ({STRING_32} "Invalid integer for " + a_parameter.name + ": " + l_token)
                    elseif a_parameter.is_multiple then
                        if parsed_values.has_parameter (a_parameter.name) then
                            parsed_values.append_integer (a_parameter.name, l_token.to_integer_32)
                        else
                            parsed_values.put_integer_list (a_parameter.name, {ARRAY [INTEGER]} <<l_token.to_integer_32>>)
                        end
                    else
                        parsed_values.put_integer (a_parameter.name, l_token.to_integer_32)
                    end
                elseif a_parameter.is_multiple then
                    if parsed_values.has_parameter (a_parameter.name) then
                        parsed_values.append_string (a_parameter.name, l_token)
                    else
                        parsed_values.put_string_list (a_parameter.name, {ARRAY [STRING_32]} <<l_token>>)
                    end
                else
                    parsed_values.put_string (a_parameter.name, l_token)
                end
            end
        end

    complete_values
            -- Report missing required values and supply defaults for absent parameters.
        do
            across parameters as p loop
                if not has_error and then not parsed_values.has_parameter (p.name) then
                    if not p.is_optional then
                        fail ({STRING_32} "Missing required parameter: " + p.name)
                    elseif p.kind = p.Flag_kind then
                        parsed_values.put_boolean (p.name, False)
                    elseif p.is_multiple then
                        if p.value_type = p.Integer_type then
                            parsed_values.put_integer_list (p.name, p.integer_list_default)
                        else
                            parsed_values.put_string_list (p.name, p.string_list_default)
                        end
                    elseif p.value_type = p.Integer_type then
                        parsed_values.put_integer (p.name, p.integer_default)
                    else
                        parsed_values.put_string (p.name, p.string_default)
                    end
                end
            end
        end

    fail (a_message: STRING_32)
        do
            last_error := a_message.twin
        end

feature {NONE} -- States

    Reading_parameters: INTEGER = unique
    Expecting_option_value: INTEGER = unique
    Reading_positionals: INTEGER = unique

feature {NONE} -- Capacity

    Default_capacity: INTEGER = 4

end
