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
            -- Recognize tokens and validate required parameters.
        require
            not_parsed: not is_parsed
        do
            parse_tokens (a_tokens)
            if not has_error then
                validate_required
            end
        ensure
            parsed: is_parsed
            outcome: is_successful xor has_error
        end

    parse_tokens (a_tokens: READABLE_INDEXABLE [STRING_32])
            -- Recognize tokens without checking required parameters.
            -- Tokens exclude the program and subcommand names.
        require
            not_parsed: not is_parsed
        local
            i, l_position, l_equals_position: INTEGER
            l_options_finished: BOOLEAN
            l_token, l_option_token: STRING_32
            l_parameter: detachable CLI_PARAMETER
            l_next_token, l_inline_value: detachable STRING_32
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
                    l_equals_position := 0
                    l_option_token := l_token
                    if not l_options_finished then
                        if l_token.count > 2 and then l_token.starts_with ("--") then
                            l_equals_position := l_token.index_of ('=', 3)
                            if l_equals_position > 0 then
                                l_option_token := l_token.substring (1, l_equals_position - 1)
                            end
                        end
                        l_parameter := named_parameter (l_option_token)
                    end
                    next_token_consumed := False
                    l_next_token := Void
                    l_inline_value := Void
                    if i < a_tokens.upper then
                        l_next_token := a_tokens [i + 1]
                    end
                    if attached l_parameter as p then
                        if l_equals_position > 0 then
                            l_inline_value := l_token.substring (l_equals_position + 1, l_token.count)
                        end
                        parse_named_parameter (p, l_option_token, l_inline_value, l_next_token)
                    elseif not l_options_finished and then is_option_token (l_token) and then
                        not is_negative_integer_argument (l_token, l_position)
                    then
                        if l_token.starts_with ("--") then
                            fail ({STRING_32} "Unknown option: " + l_token)
                        else
                            parse_short_options (l_token, l_next_token)
                        end
                    elseif l_position > positional_parameters.count then
                        fail ({STRING_32} "Unexpected argument: " + l_token)
                    else
                        store_value (positional_parameters [l_position], l_token)
                        if not positional_parameters [l_position].is_multiple then
                            l_position := l_position + 1
                        end
                    end
                    if next_token_consumed then
                        i := i + 1
                    end
                end
                i := i + 1
            end

            is_parsed := True
        ensure
            parsed: is_parsed
            not_validated: not is_validated
        end

    validate_required
            -- Check completeness after successful token recognition.
        require
            parsed: is_parsed
            no_error: not has_error
            not_validated: not is_validated
        do
            across parameters as p loop
                if not has_error and then not p.is_optional and then not seen_names.has (p.name) then
                    fail ({STRING_32} "Missing required parameter: " + p.name)
                end
            end
            is_validated := True
        ensure
            validated: is_validated
            outcome: is_successful xor has_error
        end

feature -- Status report

    is_parsed: BOOLEAN
            -- Have tokens been processed?

    is_validated: BOOLEAN
            -- Have required parameters been checked?

    is_successful: BOOLEAN
        do
            Result := is_validated and then not has_error
        end

    has_error: BOOLEAN
        do
            Result := not last_error.is_empty
        end

feature -- Result

    recognized_values: CLI_COMMAND_INPUT
            -- Recognized values and defaults; required parameters may be absent.
        require
            parsed: is_parsed
            no_error: not has_error
        do
            Result := parsed_values
        end

    values: CLI_COMMAND_INPUT
            -- Values after successful required-parameter validation.
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

    next_token_consumed: BOOLEAN
            -- Did the last named option consume the following token?

    parse_short_options (a_token: STRING_32; a_next_token: detachable STRING_32)
            -- Read flags left to right. A value option takes the entire remainder,
            -- stripping one leading '='; without a remainder it takes the next token.
        require
            short_token: a_token.count > 1 and then a_token [1] = '-' and then a_token [2] /= '-'
        local
            i: INTEGER
            l_option_token: STRING_32
            l_inline_value: detachable STRING_32
            l_finished: BOOLEAN
        do
            from i := 2 until i > a_token.count or l_finished or has_error loop
                l_option_token := {STRING_32} "-" + a_token.substring (i, i)
                if attached named_parameter (l_option_token) as p then
                    l_inline_value := Void
                    if i < a_token.count and then a_token [i + 1] = '=' then
                        l_inline_value := a_token.substring (i + 2, a_token.count)
                        l_finished := True
                    elseif p.kind /= p.Flag_kind then
                        if i < a_token.count then
                            l_inline_value := a_token.substring (i + 1, a_token.count)
                        end
                        l_finished := True
                    end
                    parse_named_parameter (p, l_option_token, l_inline_value, a_next_token)
                else
                    fail ({STRING_32} "Unknown option: " + l_option_token)
                end
                i := i + 1
            end
        end

    parse_named_parameter (a_parameter: CLI_PARAMETER; a_option_token: STRING_32;
        a_inline_value, a_next_token: detachable STRING_32)
            -- Store one option occurrence, sharing validation across all spellings.
        do
            next_token_consumed := False
            if seen_names.has (a_parameter.name) and then not a_parameter.is_multiple then
                fail ({STRING_32} "Repeated parameter: " + a_parameter.name)
            elseif a_parameter.kind = a_parameter.Flag_kind then
                if a_inline_value /= Void then
                    fail ({STRING_32} "Flag does not accept a value: " + a_option_token)
                else
                    parsed_values.put_boolean (a_parameter.name, True)
                    seen_names.force (True, a_parameter.name.twin)
                end
            elseif attached a_inline_value as l_value then
                store_value (a_parameter, l_value)
            elseif attached a_next_token as l_next_value then
                next_token_consumed := True
                store_value (a_parameter, l_next_value)
            else
                fail ({STRING_32} "Missing value for option: " + a_option_token)
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
