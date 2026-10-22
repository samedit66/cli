class
    FAKETAR_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
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
