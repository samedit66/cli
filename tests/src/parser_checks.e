class
    PARSER_CHECKS

inherit
    CLI_COMMAND
        -- Exercise parameter setup through its authorized command client.

create
    make

feature -- Command interface

    name: STRING_32 = "parser-checks"

    description: STRING_32 = "Parser regression checks"

    interface
        do
        end

    handle (a_input: CLI_COMMAND_INPUT)
        do
        end

feature {NONE} -- Checks

    make
        local
            l_parser: CLI_PARSER
            l_number, l_alias, l_strings, l_integers, l_flag: CLI_PARAMETER
            l_tokens: ARRAY [STRING_32]
        do
            create l_number.make_integer_argument ("number", "Number")
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_number>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-123">>)
            check negative_operand: l_parser.is_successful and then l_parser.values.integer_parameter ("number") = -123 end

            create l_alias.make_flag ("one", "Numeric alias")
            l_alias.set_short_name ('1')
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_number, l_alias>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-1", "-12">>)
            check numeric_alias_priority: l_parser.is_successful and then
                l_parser.values.boolean_parameter ("one") and then l_parser.values.integer_parameter ("number") = -12 end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_number, l_alias>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"--", "-1">>)
            check numeric_after_terminator: l_parser.is_successful and then
                not l_parser.values.boolean_parameter ("one") and then l_parser.values.integer_parameter ("number") = -1 end

            create l_strings.make_string_list_option ("include", "Includes")
            l_strings.set_short_name ('I')
            create l_integers.make_integer_list_option ("number", "Numbers")
            l_integers.set_short_name ('n')
            create l_flag.make_flag ("verbose", "Verbose")
            l_flag.set_short_name ('v')
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_strings, l_integers, l_flag>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-vIa", "-I=b", "--include", "c", "-n1", "-n=2", "--number", "-3">>)
            check repeated_lists: l_parser.is_successful end
            check
                string_count: l_parser.values.string_list_parameter ("include").count = 3
                string_first: l_parser.values.string_list_parameter ("include") [1].same_string_general ("a")
                string_last: l_parser.values.string_list_parameter ("include") [3].same_string_general ("c")
                integer_count: l_parser.values.integer_list_parameter ("number").count = 3
                integer_first: l_parser.values.integer_list_parameter ("number") [1] = 1
                integer_last: l_parser.values.integer_list_parameter ("number") [3] = -3
                grouped_flag: l_parser.values.boolean_parameter ("verbose")
            end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_strings>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-I=">>)
            check empty_required_list_value: l_parser.is_successful and then
                l_parser.values.string_list_parameter ("include").count = 1 and then
                l_parser.values.string_list_parameter ("include") [1].is_empty end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_strings, l_flag>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-v">>)
            check required_still_checked: l_parser.has_error and then
                l_parser.error_message.same_string_general ("Missing required parameter: include") end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_flag>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-vQ">>)
            check unknown_in_group: l_parser.has_error and then
                l_parser.error_message.same_string_general ("Unknown option: -Q") end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_flag>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"-vv">>)
            check duplicate_in_group: l_parser.has_error and then
                l_parser.error_message.same_string_general ("Repeated parameter: verbose") end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_strings>>)
            l_tokens := {ARRAY [STRING_32]} <<"-I", "-v">>
            l_tokens.rebase (4)
            l_parser.parse (l_tokens)
            check rebased_tokens: l_parser.is_successful and then
                l_parser.values.string_list_parameter ("include") [1].same_string_general ("-v") end
            check caller_tokens_unchanged: l_tokens.lower = 4 and then l_tokens [4].same_string_general ("-I") end

            io.put_string ("Parser checks passed.%N")
        end

end
