class
    GREET_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_SINGLE_COMMAND_APPLICATION
            exceptions: EXCEPTIONS
        do
            create application.make (create {GREET_COMMAND})
            application.run
            if application.has_error then
                create exceptions
                exceptions.die (2)
            end
        end

end
