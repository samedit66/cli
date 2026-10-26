note
    description: "Choice declarations exercising command APIs, aliases, defaults, and help."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class CHOICE_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = ""
            -- Default command name.

    description: STRING_32 = "Choice fixture"
            -- Description shown in help.

    interface
            -- Declare each scalar choice variant with inherited comparison constants.
        do
            add_integer_choice_argument ("level", "Level", {ARRAY [INTEGER]} <<-1, 3>>)
            add_string_choice_argument ("format", "Format", {ARRAY [STRING_32]} <<"JSON", "yaml">>, Case_insensitive)
            add_optional_integer_choice_argument ("optional-level", "Default level", {ARRAY [INTEGER]} <<0, 9>>, 9)
            add_optional_string_choice_argument ("optional-format", "Default format", {ARRAY [STRING_32]} <<"Text", "Binary">>, Case_sensitive, "Text")
            add_integer_choice_option ("number", "Number", {ARRAY [INTEGER]} <<1, 3>>)
            add_string_choice_option ("mode", "Mode", {ARRAY [STRING_32]} <<"Fast", "fast">>, Case_sensitive)
            set_short_name ("mode", 'm')
            add_optional_integer_choice_option ("count", "Count", {ARRAY [INTEGER]} <<0, 6>>, 6)
            add_optional_string_choice_option ("color", "Color", {ARRAY [STRING_32]} <<"Auto", "Never">>, Case_insensitive, "AUTO")
        end

feature -- Execution

    handle (a_values: CLI_COMMAND_INPUT)
            -- Report the canonical format and color after successful parsing.
        do
            io.put_string (a_values.string_parameter ("format").to_string_8 + "%N")
            io.put_string (a_values.string_parameter ("color").to_string_8 + "%N")
        end

end
