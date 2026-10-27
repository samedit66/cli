note
    description: "Command-line parameter definitions with types and defaults."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class CLI_PARAMETER

inherit
    CLI_STRING_ROUTINES

    CLI_CHOICE_ROUTINES

create
    make_integer_argument,
    make_optional_integer_argument,
    make_integer_option,
    make_optional_integer_option,
    make_string_argument,
    make_optional_string_argument,
    make_string_option,
    make_optional_string_option,
    make_flag,
    make_help,
    make_integer_list_argument,
    make_optional_integer_list_argument,
    make_integer_list_option,
    make_optional_integer_list_option,
    make_string_list_argument,
    make_optional_string_list_argument,
    make_string_list_option,
    make_optional_string_list_option,
    make_integer_choice_argument,
    make_optional_integer_choice_argument,
    make_integer_choice_option,
    make_optional_integer_choice_option,
    make_string_choice_argument,
    make_optional_string_choice_argument,
    make_string_choice_option,
    make_optional_string_choice_option

feature {NONE} -- Initialization

    make_integer_argument (a_name, a_description: READABLE_STRING_32)
            -- Create a required integer argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Argument_kind
            value_type := Integer_type
            is_optional := False
        end

    make_optional_integer_argument (a_name, a_description: READABLE_STRING_32; a_default: INTEGER)
            -- Create an optional integer argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Argument_kind
            value_type := Integer_type
            is_optional := True
            integer_default := a_default
        end

    make_integer_option (a_name, a_description: READABLE_STRING_32)
            -- Create a required integer option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Option_kind
            value_type := Integer_type
            is_optional := False
        end

    make_optional_integer_option (a_name, a_description: READABLE_STRING_32; a_default: INTEGER)
            -- Create an optional integer option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Option_kind
            value_type := Integer_type
            is_optional := True
            integer_default := a_default
        end

    make_string_argument (a_name, a_description: READABLE_STRING_32)
            -- Create a required string argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Argument_kind
            value_type := String_type
            is_optional := False
        end

    make_optional_string_argument (a_name, a_description: READABLE_STRING_32; a_default: READABLE_STRING_32)
            -- Create an optional string argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, a_default)
            kind := Argument_kind
            value_type := String_type
            is_optional := True
        end

    make_string_option (a_name, a_description: READABLE_STRING_32)
            -- Create a required string option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Option_kind
            value_type := String_type
            is_optional := False
        end

    make_optional_string_option (a_name, a_description: READABLE_STRING_32; a_default: READABLE_STRING_32)
            -- Create an optional string option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, a_default)
            kind := Option_kind
            value_type := String_type
            is_optional := True
        end

    make_flag (a_name, a_description: READABLE_STRING_32)
            -- Create a flag that defaults to False.
        require
            valid_name: is_valid_name (a_name)
        do
            initialize_metadata (a_name, a_description, "")
            kind := Flag_kind
            value_type := Boolean_type
            is_optional := True
        end

    make_help
            -- Create an optional help action named help.
        do
            make_flag ("help", "Show command help")
            action := Help_action
        end

    make_integer_list_argument (a_name, a_description: READABLE_STRING_32)
            -- Create a required integer list argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_integer_argument (a_name, a_description)
            is_multiple := True
        end

    make_optional_integer_list_argument (a_name, a_description: READABLE_STRING_32; a_default: ITERABLE [INTEGER])
            -- Create an optional integer list argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_integer_argument (a_name, a_description, 0)
            is_multiple := True
            across a_default as value loop
                integer_list_storage.extend (value)
            end
        end

    make_integer_list_option (a_name, a_description: READABLE_STRING_32)
            -- Create a required integer list option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_integer_option (a_name, a_description)
            is_multiple := True
        end

    make_optional_integer_list_option (a_name, a_description: READABLE_STRING_32; a_default: ITERABLE [INTEGER])
            -- Create an optional integer list option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_integer_option (a_name, a_description, 0)
            is_multiple := True
            across a_default as value loop
                integer_list_storage.extend (value)
            end
        end

    make_string_list_argument (a_name, a_description: READABLE_STRING_32)
            -- Create a required string list argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_string_argument (a_name, a_description)
            is_multiple := True
        end

    make_optional_string_list_argument (a_name, a_description: READABLE_STRING_32; a_default: ITERABLE [READABLE_STRING_32])
            -- Create an optional string list argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_string_argument (a_name, a_description, "")
            is_multiple := True
            across a_default as value loop
                string_list_storage.extend (value.to_string_32.twin)
            end
        end

    make_string_list_option (a_name, a_description: READABLE_STRING_32)
            -- Create a required string list option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_string_option (a_name, a_description)
            is_multiple := True
        end

    make_optional_string_list_option (a_name, a_description: READABLE_STRING_32; a_default: ITERABLE [READABLE_STRING_32])
            -- Create an optional string list option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_string_option (a_name, a_description, "")
            is_multiple := True
            across a_default as value loop
                string_list_storage.extend (value.to_string_32.twin)
            end
        end

feature {NONE} -- Choice initialization

    make_integer_choice_argument (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [INTEGER])
            -- Create a required integer choice argument.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_integer_choices (a_choices)
        do
            make_integer_argument (a_name, a_description)
            across a_choices as value loop
                integer_choice_storage.extend (value)
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_optional_integer_choice_argument (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [INTEGER]; a_default: INTEGER)
            -- Create a defaulted integer choice argument.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_integer_choices (a_choices)
            valid_default: has_integer_choice (a_choices, a_default)
        do
            make_integer_choice_argument (a_name, a_description, a_choices)
            is_optional := True
            integer_default := a_default
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_integer_choice_option (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [INTEGER])
            -- Create a required integer choice option.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_integer_choices (a_choices)
        do
            make_integer_option (a_name, a_description)
            across a_choices as value loop
                integer_choice_storage.extend (value)
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_optional_integer_choice_option (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [INTEGER]; a_default: INTEGER)
            -- Create a defaulted integer choice option.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_integer_choices (a_choices)
            valid_default: has_integer_choice (a_choices, a_default)
        do
            make_integer_choice_option (a_name, a_description, a_choices)
            is_optional := True
            integer_default := a_default
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_string_choice_argument (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [READABLE_STRING_32]; a_case_sensitive: BOOLEAN)
            -- Create a required string choice argument.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_string_choices (a_choices, a_case_sensitive)
        do
            make_string_argument (a_name, a_description)
            is_case_sensitive := a_case_sensitive
            across a_choices as value loop
                string_choice_storage.extend (create {IMMUTABLE_STRING_32}.make_from_string (value))
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_optional_string_choice_argument (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [READABLE_STRING_32]; a_case_sensitive: BOOLEAN; a_default: READABLE_STRING_32)
            -- Create a defaulted string choice argument.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_string_choices (a_choices, a_case_sensitive)
            valid_default: has_string_choice (a_choices, a_default, a_case_sensitive)
        do
            make_string_choice_argument (a_name, a_description, a_choices, a_case_sensitive)
            is_optional := True
            check attached matching_string_choice (a_default) as l_choice then
                string_default := l_choice
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_string_choice_option (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [READABLE_STRING_32]; a_case_sensitive: BOOLEAN)
            -- Create a required string choice option.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_string_choices (a_choices, a_case_sensitive)
        do
            make_string_option (a_name, a_description)
            is_case_sensitive := a_case_sensitive
            across a_choices as value loop
                string_choice_storage.extend (create {IMMUTABLE_STRING_32}.make_from_string (value))
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

    make_optional_string_choice_option (a_name, a_description: READABLE_STRING_32; a_choices: ITERABLE [READABLE_STRING_32]; a_case_sensitive: BOOLEAN; a_default: READABLE_STRING_32)
            -- Create a defaulted string choice option.
        require
            valid_name: is_valid_name (a_name)
            valid_choices: are_valid_string_choices (a_choices, a_case_sensitive)
            valid_default: has_string_choice (a_choices, a_default, a_case_sensitive)
        do
            make_string_choice_option (a_name, a_description, a_choices, a_case_sensitive)
            is_optional := True
            check attached matching_string_choice (a_default) as l_choice then
                string_default := l_choice
            end
        ensure
            choices_defined: has_choices
            scalar: not is_multiple
        end

feature {NONE} -- Metadata initialization

    initialize_metadata (a_name, a_description, a_string_default: READABLE_STRING_32)
            -- Snapshot metadata and establish the ordinary store action.
        require
            valid_name: is_valid_name (a_name)
        do
            create name.make_from_string (a_name)
            create description.make_from_string (a_description)
            create string_default.make_from_string (a_string_default)
            create validator_message.make_empty
            action := Store_action
        end

feature -- Value validators

    can_set_integer_validator (a_validator: FUNCTION [TUPLE [INTEGER], BOOLEAN]): BOOLEAN
            -- Can this predicate validate this parameter and its default?
        do
            Result := action = Store_action and then value_type = Integer_type and then
                not is_multiple and then not has_validator and then
                (not is_optional or else a_validator.item ([integer_default]))
        end

    set_integer_validator (a_validator: FUNCTION [TUPLE [INTEGER], BOOLEAN]; a_message: READABLE_STRING_32)
            -- Retain a pure predicate and snapshot its failure message.
        require
            assignable: can_set_integer_validator (a_validator)
            meaningful_message: not a_message.is_empty
        do
            integer_validator := a_validator
            create validator_message.make_from_string (a_message)
        ensure
            installed: has_validator
        end

    is_valid_integer_value (a_value: INTEGER): BOOLEAN
            -- Does a copy of this value satisfy the predicate, if any?
        do
            Result := True
            if attached integer_validator as v then
                Result := v.item ([a_value])
            end
        end

    can_set_string_validator (a_validator: FUNCTION [TUPLE [READABLE_STRING_32], BOOLEAN]): BOOLEAN
            -- Can this predicate validate this parameter and its default?
        do
            Result := action = Store_action and then value_type = String_type and then
                not is_multiple and then not has_validator and then
                (not is_optional or else a_validator.item ([string_default.to_string_32.twin]))
        end

    set_string_validator (a_validator: FUNCTION [TUPLE [READABLE_STRING_32], BOOLEAN]; a_message: READABLE_STRING_32)
            -- Retain a pure predicate and snapshot its failure message.
        require
            assignable: can_set_string_validator (a_validator)
            meaningful_message: not a_message.is_empty
        do
            string_validator := a_validator
            create validator_message.make_from_string (a_message)
        ensure
            installed: has_validator
        end

    is_valid_string_value (a_value: READABLE_STRING_32): BOOLEAN
            -- Does a copy of this value satisfy the predicate, if any?
        do
            Result := True
            if attached string_validator as v then
                Result := v.item ([a_value.to_string_32.twin])
            end
        end

    can_set_integer_list_validator (a_validator: FUNCTION [TUPLE [ARRAYED_LIST [INTEGER]], BOOLEAN]): BOOLEAN
            -- Can this predicate validate this parameter and its default?
        do
            Result := action = Store_action and then value_type = Integer_type and then
                is_multiple and then not has_validator and then
                (not is_optional or else a_validator.item ([integer_list_default]))
        end

    set_integer_list_validator (a_validator: FUNCTION [TUPLE [ARRAYED_LIST [INTEGER]], BOOLEAN]; a_message: READABLE_STRING_32)
            -- Retain a pure predicate and snapshot its failure message.
        require
            assignable: can_set_integer_list_validator (a_validator)
            meaningful_message: not a_message.is_empty
        do
            integer_list_validator := a_validator
            create validator_message.make_from_string (a_message)
        ensure
            installed: has_validator
        end

    is_valid_integer_list_value (a_value: ARRAYED_LIST [INTEGER]): BOOLEAN
            -- Does a copy of this value satisfy the predicate, if any?
        do
            Result := True
            if attached integer_list_validator as v then
                Result := v.item ([a_value.twin])
            end
        end

    can_set_string_list_validator (a_validator: FUNCTION [TUPLE [ARRAYED_LIST [STRING_32]], BOOLEAN]): BOOLEAN
            -- Can this predicate validate this parameter and its default?
        do
            Result := action = Store_action and then value_type = String_type and then
                is_multiple and then not has_validator and then
                (not is_optional or else a_validator.item ([string_list_default]))
        end

    set_string_list_validator (a_validator: FUNCTION [TUPLE [ARRAYED_LIST [STRING_32]], BOOLEAN]; a_message: READABLE_STRING_32)
            -- Retain a pure predicate and snapshot its failure message.
        require
            assignable: can_set_string_list_validator (a_validator)
            meaningful_message: not a_message.is_empty
        do
            string_list_validator := a_validator
            create validator_message.make_from_string (a_message)
        ensure
            installed: has_validator
        end

    is_valid_string_list_value (a_value: ARRAYED_LIST [STRING_32]): BOOLEAN
            -- Does a copy of this value satisfy the predicate, if any?
        do
            Result := True
            if attached string_list_validator as v then
                Result := v.item ([copied_strings (a_value)])
            end
        end

    has_validator: BOOLEAN
            -- Is a value predicate installed?
        do
            Result := integer_validator /= Void or string_validator /= Void or
                integer_list_validator /= Void or string_list_validator /= Void
        end

    validator_message: IMMUTABLE_STRING_32
            -- Diagnostic for a rejected value; empty until a validator is installed.

feature {NONE} -- Validator implementation

    integer_validator: detachable FUNCTION [TUPLE [INTEGER], BOOLEAN]

    string_validator: detachable FUNCTION [TUPLE [READABLE_STRING_32], BOOLEAN]

    integer_list_validator: detachable FUNCTION [TUPLE [ARRAYED_LIST [INTEGER]], BOOLEAN]

    string_list_validator: detachable FUNCTION [TUPLE [ARRAYED_LIST [STRING_32]], BOOLEAN]

    copied_strings (a_values: ARRAYED_LIST [STRING_32]): ARRAYED_LIST [STRING_32]
            -- Independent copy of the list and its strings.
        do
            create Result.make (a_values.count)
            across a_values as v loop
                Result.extend (v.twin)
            end
        end

feature -- Validation

    is_valid_name (a_name: READABLE_STRING_32): BOOLEAN
            -- Is `a_name` a nonempty parameter name without separators or a leading dash?
        do
            Result := is_valid_parameter_name (a_name)
        end

feature -- Actions

    Store_action: INTEGER = unique
            -- Store the parsed value.

    Help_action: INTEGER = unique
            -- Request help without completing required-parameter validation.

    action: INTEGER
            -- Action performed when this parameter is recognized.

feature -- Access

    name: IMMUTABLE_STRING_32
            -- Parameter name without option prefixes.

    description: IMMUTABLE_STRING_32
            -- Description shown in generated help.

    kind: INTEGER
            -- Parameter kind: argument, option, or flag.

    value_type: INTEGER
            -- Parameter value type: integer, string, or Boolean.

    is_optional: BOOLEAN
            -- May this parameter be omitted?

    is_multiple: BOOLEAN
            -- Does this parameter collect a sequence of values?

    has_short_name: BOOLEAN
            -- Is a short alias assigned?

    short_name: CHARACTER_32
            -- Short alias, meaningful when `has_short_name` is True.

    integer_default: INTEGER
            -- Default for an optional integer parameter.

    string_default: IMMUTABLE_STRING_32
            -- Default for an optional string parameter.

    integer_list_default: ARRAYED_LIST [INTEGER]
            -- Copy of the default integer values.
        do
            Result := integer_list_storage.twin
        end

    string_list_default: ARRAYED_LIST [STRING_32]
            -- Copy of the default string values, including their strings.
        do
            create Result.make (string_list_storage.count)
            across string_list_storage as value loop
                Result.extend (value.twin)
            end
        end

feature -- Choices

    has_choices: BOOLEAN
            -- Is this scalar parameter restricted to declared choices?
        do
            Result := not integer_choice_storage.is_empty or else not string_choice_storage.is_empty
        end

    is_case_sensitive: BOOLEAN
            -- Are string choices compared with exact casing?

    accepts_integer_choice (a_value: INTEGER): BOOLEAN
            -- Is `a_value` one of the declared integer choices?
        require
            integer_choice: has_choices and value_type = Integer_type
        do
            Result := integer_choice_storage.has (a_value)
        end

    matching_string_choice (a_value: READABLE_STRING_32): detachable IMMUTABLE_STRING_32
            -- Declared spelling matching `a_value`, or Void; immutable shared result.
        require
            string_choice: has_choices and value_type = String_type
        do
            across string_choice_storage as value loop
                if matching_choice_strings (value, a_value, is_case_sensitive) then
                    Result := value
                end
            end
        end

    choices_text: STRING_32
            -- Fresh display of choices in declaration order, with quoted strings.
        require
            choice_parameter: has_choices
        do
            create Result.make_empty
            across integer_choice_storage as value loop
                if not Result.is_empty then Result.append (", ") end
                Result.append_string_general (value.out)
            end
            across string_choice_storage as value loop
                if not Result.is_empty then Result.append (", ") end
                Result.append_character ('%"')
                Result.append (value)
                Result.append_character ('%"')
            end
        end

feature {NONE} -- Choice storage

    integer_choice_storage: ARRAYED_LIST [INTEGER]
        attribute
            create Result.make (Default_capacity)
        end

    string_choice_storage: ARRAYED_LIST [IMMUTABLE_STRING_32]
        attribute
            create Result.make (Default_capacity)
        end

feature {NONE} -- Defaults

    integer_list_storage: ARRAYED_LIST [INTEGER]
        attribute
            create Result.make (Default_capacity)
        end

    string_list_storage: ARRAYED_LIST [STRING_32]
        attribute
            create Result.make (Default_capacity)
        end

feature {NONE} -- Capacity

    Default_capacity: INTEGER = 4

feature {CLI_COMMAND} -- Short name assignment

    remove_short_name
            -- Release an automatically assigned alias.
        require
            help_action: action = Help_action
        do
            has_short_name := False
        ensure
            removed: not has_short_name
        end

    set_short_name (a_short_name: CHARACTER_32)
            -- Assign a short name during command definition.
        require
            option_or_flag: kind /= Argument_kind
            not_assigned: not has_short_name
            valid_short_name: a_short_name.is_alpha
        do
            short_name := a_short_name
            has_short_name := True
        ensure
            assigned: has_short_name
            short_name_set: short_name = a_short_name
        end

feature -- Kinds

    Argument_kind: INTEGER = unique
            -- Argument parameter kind.
    Option_kind: INTEGER = unique
            -- Option parameter kind.
    Flag_kind: INTEGER = unique
            -- Flag parameter kind.

feature -- Value types

    Integer_type: INTEGER = unique
            -- Integer parameter value type.
    String_type: INTEGER = unique
            -- String parameter value type.
    Boolean_type: INTEGER = unique
            -- Boolean parameter value type.

invariant
    scalar_choices: has_choices implies not is_multiple and kind /= Flag_kind
    integer_choices_typed: not integer_choice_storage.is_empty implies value_type = Integer_type
    string_choices_typed: not string_choice_storage.is_empty implies value_type = String_type
    valid_integer_choices: not integer_choice_storage.is_empty implies are_valid_integer_choices (integer_choice_storage)
    valid_string_choices: not string_choice_storage.is_empty implies are_valid_string_choices (string_choice_storage, is_case_sensitive)
    integer_choice_default: has_choices and is_optional and value_type = Integer_type implies accepts_integer_choice (integer_default)
    string_choice_default: has_choices and is_optional and value_type = String_type implies matching_string_choice (string_default) /= Void
    valid_action: action = Store_action or action = Help_action
    help_is_flag: action = Help_action implies kind = Flag_kind
    no_flag_lists: is_multiple implies kind /= Flag_kind
    non_empty_name: not name.is_empty
    valid_kind: kind = Argument_kind or kind = Option_kind or kind = Flag_kind
    valid_type: value_type = Integer_type or value_type = String_type or value_type = Boolean_type
    boolean_is_flag: (value_type = Boolean_type) = (kind = Flag_kind)
    optional_flag: kind = Flag_kind implies is_optional
    short_name_for_option_or_flag: has_short_name implies kind /= Argument_kind
    valid_short_name: has_short_name implies short_name.is_alpha

end
