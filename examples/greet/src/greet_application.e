class
    GREET_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_APPLICATION
            command: GREET_COMMAND
        do
            create command
            create application.make ("greet", command.description)
            application.add_command (command)
            application.run
        end

end
