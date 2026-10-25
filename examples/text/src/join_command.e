note
    description: "Commands that join words into a single line."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class JOIN_COMMAND

inherit
    CLI_COMMAND

feature -- Definition

    name: STRING_32 = "join"
            -- Command name used for selection.

    description: STRING_32 = "Join words into a single line"
            -- Description shown in generated help.

    interface
            -- Declare the command parameters.
        do
            add_string_list_argument ("parts", "Text parts to join")
            add_optional_string_option ("separator", "Separator between parts", " ")
            set_short_name ("separator", 's')
            add_flag ("upper", "Convert the result to uppercase")
            set_short_name ("upper", 'u')
        end

feature -- Execution

    handle (a_input: CLI_COMMAND_INPUT)
            -- Print the joined words.
        local
            parts: ARRAYED_LIST [STRING_32]
            separator, result_text: STRING_32
            i: INTEGER
        do
            parts := a_input.string_list_parameter ("parts")
            separator := a_input.string_parameter ("separator")
            create result_text.make_empty
            from i := 1 until i > parts.count loop
                if i > 1 then
                    result_text.append (separator)
                end
                result_text.append (parts [i])
                i := i + 1
            end
            if a_input.boolean_parameter ("upper") then
                result_text.to_upper
            end
            io.put_string_32 (result_text + "%N")
        end

end
