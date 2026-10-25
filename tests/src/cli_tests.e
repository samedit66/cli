note
    description: "Assertion-enabled parser and command-routing tests."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class CLI_TESTS

create
    make

feature {NONE} -- Entry point

    make
            -- Run parser tests or the requested routing fixture.
        local
            l_arguments: ARGUMENTS_32
            l_application: CLI_APPLICATION
            l_tokens: ARRAYED_LIST [STRING_32]
            l_immutable_tokens: ARRAYED_LIST [IMMUTABLE_STRING_32]
            i: INTEGER
        do
            create l_arguments
            if l_arguments.argument_count = 0 then
                test_command_names
                test_readable_inputs
                test_application_lifecycle
                test_definition_validation
                test_values
                test_inline_values
                test_failures
                test_token_ownership
                test_split
                test_default_help
                io.put_string ("parser tests passed%N")
            else
                create l_application.make ("routing", "Command routing tests")
                if l_arguments.argument (1).starts_with ("automatic") then
                    if l_arguments.argument (1).same_string ("automatic-custom") then
                        l_application.add_command (create {AUTOMATIC_HELP_COMMAND}.make_custom)
                    else
                        l_application.add_command (create {AUTOMATIC_HELP_COMMAND}.make (
                            l_arguments.argument (1).same_string ("automatic-conflict")))
                    end
                elseif l_arguments.argument (1).same_string ("single-required") then
                    l_application.add_command (create {ROUTING_COMMAND}.make_required (""))
                else
                    if l_arguments.argument (1).same_string ("route-root-first") then
                        l_application.add_command (create {ROUTING_COMMAND}.make (""))
                    end
                    -- Register longer names first to test selection independently of order.
                    l_application.add_command (create {ROUTING_COMMAND}.make ("remote add deep"))
                    l_application.add_command (create {ROUTING_COMMAND}.make ("remote add"))
                    l_application.add_command (create {ROUTING_COMMAND}.make ("remote required"))
                    l_application.add_command (create {ROUTING_COMMAND}.make ("remote"))
                    l_application.add_command (create {ROUTING_COMMAND}.make ("lonely child"))
                    l_application.add_command (create {CLI_HELP_COMMAND}.make (l_application))
                    if l_arguments.argument (1).same_string ("route") then
                        l_application.add_command (create {ROUTING_COMMAND}.make (""))
                    end
                end
                create l_tokens.make (l_arguments.argument_count - 1)
                from i := 2 until i > l_arguments.argument_count loop
                    l_tokens.extend (l_arguments.argument (i))
                    i := i + 1
                end
                if l_arguments.argument (1).same_string ("automatic-immutable") then
                    create l_immutable_tokens.make (l_tokens.count)
                    across l_tokens as token loop
                        l_immutable_tokens.extend (create {IMMUTABLE_STRING_32}.make_from_string (token))
                    end
                    l_application.run_with_tokens (l_immutable_tokens)
                else
                    l_application.run_with_tokens (l_tokens)
                end
            end
        end

feature {NONE} -- Parser tests

    test_command_names
        local
            l_name: STRING_32
            l_command: ROUTING_COMMAND
            l_application: CLI_APPLICATION
        do
            l_name := "pack"
            create l_command.make (l_name)
            create l_application.make ("tool", "Name ownership tests")
            l_application.add_command (l_command)
            l_name.replace_substring_all ("pack", "list")
            check
                copied_name: l_command.name.same_string ("pack")
                registered_name_stable: l_application.has_command ("pack")
                caller_mutation_isolated: not l_application.has_command ("list")
                invocation_stable: l_application.command_help ("pack").has_substring ("tool pack")
            end
        end

    test_readable_inputs
        local
            l_name, l_default, l_token: IMMUTABLE_STRING_32
            l_parameter: CLI_PARAMETER
            l_parser: CLI_PARSER
            l_application: CLI_APPLICATION
            l_command: AUTOMATIC_HELP_COMMAND
        do
            create l_name.make_from_string ("value")
            create l_default.make_from_string ("default")
            create l_token.make_from_string ("supplied")
            create l_parameter.make_optional_string_argument (l_name, l_name, l_default)
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_parameter>>)
            l_parser.parse ({ARRAY [IMMUTABLE_STRING_32]} <<l_token>>)
            check
                immutable_token: l_parser.is_successful and then
                    l_parser.values.string_parameter (l_name).same_string (l_token)
                immutable_default: l_parameter.string_default.same_string (l_default)
            end
            create l_parameter.make_optional_string_list_option (l_name, l_name,
                {ARRAY [IMMUTABLE_STRING_32]} <<l_default>>)
            check
                immutable_list_default: l_parameter.string_list_default.first.same_string (l_default)
            end
            create l_command.make (False)
            l_command.add_optional_string_option (l_name, l_name, l_default)
            l_command.add_optional_string_list_option ("items", l_name,
                {ARRAY [IMMUTABLE_STRING_32]} <<l_default>>)
            create l_application.make_single_command (l_name, l_command)
            check
                immutable_application_name: l_application.name.same_string (l_name)
            end
        end

    test_application_lifecycle
        local
            l_first: CLI_APPLICATION
            l_command: AUTOMATIC_HELP_COMMAND
            l_parser: CLI_PARSER
            l_help: CLI_PARAMETER
            l_parameter: CLI_PARAMETER
        do
            create l_command.make (False)
            create l_first.make_single_command ("first", l_command)
            l_command.add_flag ("extra", "Added after registration")
            l_command.set_short_name ("extra", 'x')
            check
                initialized_once: l_command.interface_count = 1
                extension_visible: l_first.command_help ("").has_substring ("-x, --extra")
                automatic_help_visible: l_first.command_help ("").has_substring ("-h, --help")
            end
            l_command.add_flag ("heading", "Late alias assignment")
            l_command.set_short_name ("heading", 'h')
            check
                automatic_alias_released: not l_first.command_help ("").has_substring ("-h, --help")
                explicit_alias_assigned: l_first.command_help ("").has_substring ("-h, --heading")
            end
            l_command.add_flag ("help", "Custom help")
            check
                automatic_definition_replaced: not l_first.command_help ("").has_substring ("Show command help")
                custom_definition_visible: l_first.command_help ("").has_substring ("Custom help")
            end
            create l_help.make_help
            create l_parameter.make_integer_argument ("count", "")
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<l_parameter, l_help>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"--help">>)
            check
                help_bypasses_required: l_parser.help_requested and not l_parser.has_error
                separate_outcome: not l_parser.is_successful
                duplicate_definitions: not l_parser.are_valid_definitions (
                    {ARRAY [CLI_PARAMETER]} <<l_parameter, l_parameter>>)
            end
            create l_parameter.make_optional_string_list_argument ("items", "", {ARRAY [STRING_32]} <<"original">>)
            l_parameter.string_list_default.first.wipe_out
            check
                copied_defaults: l_parameter.string_list_default.first.same_string ("original")
            end
        end

    test_definition_validation
        local
            l_parameter: CLI_PARAMETER
            l_application: CLI_APPLICATION
            l_command: ROUTING_COMMAND
        do
            create l_parameter.make_flag ("verbose", "")
            create l_application.make ("tool", "")
            create l_command.make ("")
            check
                parameter_name: l_parameter.is_valid_name ("file-name")
                empty_parameter: not l_parameter.is_valid_name ("")
                spaced_parameter: not l_parameter.is_valid_name ("file name")
                equals_parameter: not l_parameter.is_valid_name ("file=name")
                dashed_parameter: not l_parameter.is_valid_name ("-file")
                default_command: l_application.is_valid_command_name ("")
                multiword_command: l_application.is_valid_command_name ("remote add")
                leading_space: not l_application.is_valid_command_name (" remote")
                trailing_space: not l_application.is_valid_command_name ("remote ")
                double_space: not l_application.is_valid_command_name ("remote  add")
                tab: not l_application.is_valid_command_name ("remote%Tadd")
                newline: not l_application.is_valid_command_name ("remote%Nadd")
                carriage_return: not l_application.is_valid_command_name ("remote%Radd")
                option_word: not l_application.is_valid_command_name ("remote -add")
                initially_empty: not l_command.has_parameter ("files")
            end
            l_command.add_optional_string_list_argument ("files", "", {ARRAY [STRING_32]} <<>>)
            check
                registered_name: l_command.has_parameter ("files")
                positional_list: l_command.has_positional_list
                optional_argument: l_command.has_optional_argument
            end
        end


    test_default_help
        local
            l_application: CLI_APPLICATION
            l_help: STRING_32
        do
            create l_application.make ("single", "One default command")
            l_application.add_command (create {ROUTING_COMMAND}.make (""))
            l_help := l_application.command_help ("")
            check
                default_registered: l_application.has_command ("")
                invocation_name: l_help.has_substring ("Usage:%N  single [arguments...]")
                parameter_help: l_help.has_substring ("--tag")
                application_overview: l_application.help.has_substring ("(default)")
            end
        end

    test_values
        local
            l_parameters: ARRAY [CLI_PARAMETER]
            l_parser: CLI_PARSER
            l_values: CLI_COMMAND_INPUT
        do
            l_parameters := <<
                create {CLI_PARAMETER}.make_optional_string_argument ("first", "", "first-default"),
                create {CLI_PARAMETER}.make_optional_integer_list_argument ("rest", "", {ARRAY [INTEGER]} <<11, 12>>),
                create {CLI_PARAMETER}.make_optional_integer_option ("count", "", 4),
                create {CLI_PARAMETER}.make_optional_string_option ("label", "", "default"),
                create {CLI_PARAMETER}.make_optional_string_list_option ("tag", "", {ARRAY [STRING_32]} <<"default">>),
                create {CLI_PARAMETER}.make_optional_integer_list_option ("number", "", {ARRAY [INTEGER]} <<8, 9>>),
                create {CLI_PARAMETER}.make_flag ("verbose", "")
            >>
            create l_parser.make (l_parameters)
            l_parser.parse ({ARRAY [STRING_32]} <<>>)
            check defaults_successful: l_parser.is_successful end
            l_values := l_parser.values
            check
                string_default: l_values.string_parameter ("first").same_string ("first-default")
                integer_default: l_values.integer_parameter ("count") = 4
                string_option_default: l_values.string_parameter ("label").same_string ("default")
                positional_list_default: l_values.integer_list_parameter ("rest").count = 2
                string_list_default: l_values.string_list_parameter ("tag").first.same_string ("default")
                integer_list_default: l_values.integer_list_parameter ("number").first = 8
                flag_default: not l_values.boolean_parameter ("verbose")
            end

            create l_parser.make (l_parameters)
            l_parser.parse ({ARRAY [STRING_32]} <<
                "", "--count=-2147483648", "--tag", "", "--tag", "a,b",
                "--number=-3", "--number", "2147483647", "--verbose", "--", "-1", "2"
            >>)
            check explicit_values_successful: l_parser.is_successful end
            l_values := l_parser.values
            check
                empty_is_explicit: l_values.has_parameter ("first") and then l_values.string_parameter ("first").is_empty
                minimum_integer: l_values.integer_parameter ("count") = {INTEGER}.min_value
                positional_list_replaced: l_values.integer_list_parameter ("rest").first = -1
                positional_list_appended: l_values.integer_list_parameter ("rest").count = 2
                string_list_replaced: l_values.string_list_parameter ("tag").first.is_empty
                no_implicit_split: l_values.string_list_parameter ("tag") [2].same_string ("a,b")
                integer_list_replaced: l_values.integer_list_parameter ("number").first = -3
                integer_list_appended: l_values.integer_list_parameter ("number") [2] = {INTEGER}.max_value
                flag_set: l_values.boolean_parameter ("verbose")
                definitions_unchanged: l_parameters [2].integer_list_default.first = 11
            end

            create l_parser.make (
                {ARRAY [CLI_PARAMETER]} <<create {CLI_PARAMETER}.make_string_list_argument ("files", "")>>)
            l_parser.parse ({ARRAY [STRING_32]} <<"a", "b">>)
            check required_list_filled: l_parser.is_successful and then l_parser.values.string_list_parameter ("files").count = 2 end

            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<>>)
            l_parser.parse ({ARRAY [STRING_32]} <<>>)
            check empty_schema: l_parser.is_successful and then not l_parser.values.has_parameter ("unknown") end
        end

    test_inline_values
        local
            l_parameters: ARRAY [CLI_PARAMETER]
            l_parser: CLI_PARSER
            l_values: CLI_COMMAND_INPUT
        do
            l_parameters := <<
                create {CLI_PARAMETER}.make_string_argument ("archive", ""),
                create {CLI_PARAMETER}.make_string_option ("password", ""),
                create {CLI_PARAMETER}.make_integer_option ("count", ""),
                create {CLI_PARAMETER}.make_optional_string_list_option ("tag", "", {ARRAY [STRING_32]} <<"default">>),
                create {CLI_PARAMETER}.make_flag ("keep-root", "")
            >>
            create l_parser.make (l_parameters)
            l_parser.parse ({ARRAY [STRING_32]} <<
                "--password=--keep-root", "--tag=--help", "--tag=a=b", "--tag=", "--count=-3", "--keep-root", "--", "--archive"
            >>)
            check inline_values_successful: l_parser.is_successful end
            l_values := l_parser.values
            check
                option_like_value: l_values.string_parameter ("password").same_string ("--keep-root")
                first_equals_only: l_values.string_list_parameter ("tag") [2].same_string ("a=b")
                empty_list_item: l_values.string_list_parameter ("tag") [3].is_empty
                list_default_replaced: l_values.string_list_parameter ("tag").count = 3
                negative_integer: l_values.integer_parameter ("count") = -3
                next_flag_recognized: l_values.boolean_parameter ("keep-root")
                separator_preserved: l_values.string_parameter ("archive").same_string ("--archive")
            end

            create l_parser.make (l_parameters)
            l_parser.parse ({ARRAY [STRING_32]} <<"--password=", "--count=0", "archive.zip">>)
            check
                empty_scalar_successful: l_parser.is_successful
                empty_scalar_explicit: l_parser.values.string_parameter ("password").is_empty
                default_preserved: l_parser.values.string_list_parameter ("tag").first.same_string ("default")
                unset_flag: not l_parser.values.boolean_parameter ("keep-root")
            end
        end

    test_failures
        do
            assert_error (create {CLI_PARAMETER}.make_string_argument ("file", ""),
                {ARRAY [STRING_32]} <<>>, "Missing required parameter: file")
            assert_error (create {CLI_PARAMETER}.make_string_list_argument ("files", ""),
                {ARRAY [STRING_32]} <<>>, "Missing required parameter: files")
            assert_error (create {CLI_PARAMETER}.make_integer_list_option ("numbers", ""),
                {ARRAY [STRING_32]} <<>>, "Missing required parameter: numbers")
            assert_error (create {CLI_PARAMETER}.make_integer_list_option ("numbers", ""),
                {ARRAY [STRING_32]} <<"--numbers">>, "Missing value for option: --numbers")
            assert_error (create {CLI_PARAMETER}.make_integer_option ("count", ""),
                {ARRAY [STRING_32]} <<"--count", "2147483648">>, "Invalid integer for count: 2147483648")
            assert_error (create {CLI_PARAMETER}.make_integer_option ("count", ""),
                {ARRAY [STRING_32]} <<"--count=-2147483649">>, "Invalid integer for count: -2147483649")
            assert_error (create {CLI_PARAMETER}.make_string_option ("password", ""),
                {ARRAY [STRING_32]} <<"--password", "--keep-root">>, "Missing value for option: --password")
            assert_error (create {CLI_PARAMETER}.make_string_option ("password", ""),
                {ARRAY [STRING_32]} <<"--password", "-p">>, "Missing value for option: --password")
            assert_error (create {CLI_PARAMETER}.make_string_option ("password", ""),
                {ARRAY [STRING_32]} <<"--password", "--">>, "Missing value for option: --password")
            assert_error (create {CLI_PARAMETER}.make_integer_option ("count", ""),
                {ARRAY [STRING_32]} <<"--count", "-3">>, "Missing value for option: --count")
            assert_error (create {CLI_PARAMETER}.make_flag ("help", ""),
                {ARRAY [STRING_32]} <<"--help=true">>, "Flag does not accept a value: --help")
            assert_error (create {CLI_PARAMETER}.make_flag ("help", ""),
                {ARRAY [STRING_32]} <<"--help=">>, "Flag does not accept a value: --help")
            assert_error (create {CLI_PARAMETER}.make_integer_list_option ("numbers", ""),
                {ARRAY [STRING_32]} <<"--numbers=">>, "Invalid integer for numbers: ")
            assert_error (create {CLI_PARAMETER}.make_integer_argument ("number", ""),
                {ARRAY [STRING_32]} <<"-3">>, "Unknown option: -3")
            assert_error (create {CLI_PARAMETER}.make_string_argument ("file", ""),
                {ARRAY [STRING_32]} <<"a", "b", "c">>, "Unexpected argument: b")
        end

    assert_error (a_parameter: CLI_PARAMETER; a_tokens: ARRAY [STRING_32]; a_error: STRING_32)
        local
            l_parser: CLI_PARSER
        do
            create l_parser.make ({ARRAY [CLI_PARAMETER]} <<a_parameter>>)
            l_parser.parse (a_tokens)
            check
                finished: l_parser.is_parsed
                failed: l_parser.has_error and then not l_parser.is_successful
                diagnostic: l_parser.error_message.same_string (a_error)
            end
        end

    test_token_ownership
        local
            l_tokens: ARRAY [STRING_32]
            l_parser: CLI_PARSER
        do
            create l_tokens.make_filled ("", -2, -1)
            l_tokens [-2] := "--label"
            l_tokens [-1] := "original"
            create l_parser.make (
                {ARRAY [CLI_PARAMETER]} <<create {CLI_PARAMETER}.make_string_option ("label", "")>>)
            l_parser.parse (l_tokens)
            check
                input_bounds_unchanged: l_tokens.lower = -2 and then l_tokens.upper = -1
                input_tokens_unchanged: l_tokens [-2].same_string ("--label") and then l_tokens [-1].same_string ("original")
            end
            l_tokens [-1].append (" changed")
            check independent_value: l_parser.is_successful and then l_parser.values.string_parameter ("label").same_string ("original") end
        end

    test_split
        local
            l_routines: CLI_STRING_ROUTINES
            l_parts: ARRAYED_LIST [STRING_32]
        do
            create l_routines
            l_parts := l_routines.split (", a,,b,", ',')
            check
                empty_parts_preserved: l_parts.count = 5 and then l_parts.first.is_empty and then l_parts.last.is_empty
                whitespace_preserved: l_parts [2].same_string (" a")
                middle_empty_preserved: l_parts [3].is_empty
                empty_input_preserved: l_routines.split ("", ',').count = 1
            end
        end

end
