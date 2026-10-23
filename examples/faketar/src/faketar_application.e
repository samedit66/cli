note
    description: "Entry points for the faketar example application."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class
    FAKETAR_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
            -- Run the example application.
        local
            application: CLI_APPLICATION
            command: FAKETAR_COMMAND
        do
            create command
            create application.make ("faketar", command.description)
            application.add_command (command)
            application.run
        end

end
