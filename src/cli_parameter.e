note
    description: "Command-line parameter definitions with types and defaults."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    CLI_PARAMETER

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
    make_integer_list_argument,
    make_optional_integer_list_argument,
    make_integer_list_option,
    make_optional_integer_list_option,
    make_string_list_argument,
    make_optional_string_list_argument,
    make_string_list_option,
    make_optional_string_list_option

feature {NONE} -- Initialization

    make_integer_argument (a_name, a_description: STRING_32)
            -- Create a required integer argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Argument_kind
            value_type := Integer_type
            is_optional := False
        end

    make_optional_integer_argument (a_name, a_description: STRING_32; a_default: INTEGER)
            -- Create an optional integer argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Argument_kind
            value_type := Integer_type
            is_optional := True
            integer_default := a_default
        end

    make_integer_option (a_name, a_description: STRING_32)
            -- Create a required integer option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Option_kind
            value_type := Integer_type
            is_optional := False
        end

    make_optional_integer_option (a_name, a_description: STRING_32; a_default: INTEGER)
            -- Create an optional integer option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Option_kind
            value_type := Integer_type
            is_optional := True
            integer_default := a_default
        end

    make_string_argument (a_name, a_description: STRING_32)
            -- Create a required string argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Argument_kind
            value_type := String_type
            is_optional := False
        end

    make_optional_string_argument (a_name, a_description: STRING_32; a_default: STRING_32)
            -- Create an optional string argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Argument_kind
            value_type := String_type
            is_optional := True
            string_default := a_default.twin
        end

    make_string_option (a_name, a_description: STRING_32)
            -- Create a required string option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Option_kind
            value_type := String_type
            is_optional := False
        end

    make_optional_string_option (a_name, a_description: STRING_32; a_default: STRING_32)
            -- Create an optional string option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Option_kind
            value_type := String_type
            is_optional := True
            string_default := a_default.twin
        end

    make_flag (a_name, a_description: STRING_32)
            -- Create a flag that defaults to False.
        require
            valid_name: is_valid_name (a_name)
        do
            name := a_name.twin
            description := a_description.twin
            create string_default.make_empty
            kind := Flag_kind
            value_type := Boolean_type
            is_optional := True
        end

    make_integer_list_argument (a_name, a_description: STRING_32)
            -- Create a required integer list argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_integer_argument (a_name, a_description)
            is_multiple := True
        end

    make_optional_integer_list_argument (a_name, a_description: STRING_32; a_default: ITERABLE [INTEGER])
            -- Create an optional integer list argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_integer_argument (a_name, a_description, 0)
            is_multiple := True
            across a_default as value loop
                integer_list_default.extend (value)
            end
        end

    make_integer_list_option (a_name, a_description: STRING_32)
            -- Create a required integer list option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_integer_option (a_name, a_description)
            is_multiple := True
        end

    make_optional_integer_list_option (a_name, a_description: STRING_32; a_default: ITERABLE [INTEGER])
            -- Create an optional integer list option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_integer_option (a_name, a_description, 0)
            is_multiple := True
            across a_default as value loop
                integer_list_default.extend (value)
            end
        end

    make_string_list_argument (a_name, a_description: STRING_32)
            -- Create a required string list argument parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_string_argument (a_name, a_description)
            is_multiple := True
        end

    make_optional_string_list_argument (a_name, a_description: STRING_32; a_default: ITERABLE [STRING_32])
            -- Create an optional string list argument parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_string_argument (a_name, a_description, "")
            is_multiple := True
            across a_default as value loop
                string_list_default.extend (value.twin)
            end
        end

    make_string_list_option (a_name, a_description: STRING_32)
            -- Create a required string list option parameter.
        require
            valid_name: is_valid_name (a_name)
        do
            make_string_option (a_name, a_description)
            is_multiple := True
        end

    make_optional_string_list_option (a_name, a_description: STRING_32; a_default: ITERABLE [STRING_32])
            -- Create an optional string list option parameter with an explicit default.
        require
            valid_name: is_valid_name (a_name)
        do
            make_optional_string_option (a_name, a_description, "")
            is_multiple := True
            across a_default as value loop
                string_list_default.extend (value.twin)
            end
        end

feature -- Validation

    is_valid_name (a_name: STRING_32): BOOLEAN
            -- Is `a_name` a nonempty parameter name without separators or a leading dash?
        do
            Result := not a_name.is_empty and then not a_name.has (' ') and then not a_name.has ('=') and then not a_name.starts_with ("-")
        end

feature -- Access

    name: STRING_32
            -- Parameter name without option prefixes.

    description: STRING_32
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

    string_default: STRING_32
            -- Default for an optional string parameter.

    integer_list_default: ARRAYED_LIST [INTEGER]
            -- Owned default values for an optional integer list parameter.
        attribute
            create Result.make (Default_capacity)
        end

    string_list_default: ARRAYED_LIST [STRING_32]
            -- Owned default values for an optional string list parameter.
        attribute
            create Result.make (Default_capacity)
        end

feature {NONE} -- Capacity

    Default_capacity: INTEGER = 4

feature {CLI_COMMAND} -- Short name assignment

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
    no_flag_lists: is_multiple implies kind /= Flag_kind
    non_empty_name: not name.is_empty
    valid_kind: kind = Argument_kind or kind = Option_kind or kind = Flag_kind
    valid_type: value_type = Integer_type or value_type = String_type or value_type = Boolean_type
    boolean_is_flag: (value_type = Boolean_type) = (kind = Flag_kind)
    optional_flag: kind = Flag_kind implies is_optional
    short_name_for_option_or_flag: has_short_name implies kind /= Argument_kind
    valid_short_name: has_short_name implies short_name.is_alpha

end
