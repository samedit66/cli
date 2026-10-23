note
    description: "Entry points for the text example application."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    TEXT_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
            -- Run the example application.
        local
            application: CLI_APPLICATION
        do
            create application.make ("text", "Join and repeat text")
            application.add_command (create {JOIN_COMMAND})
            application.add_command (create {REPEAT_COMMAND})
            application.add_command (create {CLI_HELP_COMMAND}.make (application))
            application.run
        end

end
