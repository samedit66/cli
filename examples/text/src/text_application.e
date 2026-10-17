class
    TEXT_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_APPLICATION
            exceptions: EXCEPTIONS
        do
            create application.make ("text", "Join and repeat text")
            application.add_command (create {JOIN_COMMAND})
            application.add_command (create {REPEAT_COMMAND})
            application.run
            if application.has_error then
                create exceptions
                exceptions.die (2)
            end
        end

end
