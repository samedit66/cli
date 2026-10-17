class
    TEXT_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_APPLICATION
        do
            create application.make ("text", "Join and repeat text")
            application.add_command (create {JOIN_COMMAND})
            application.add_command (create {REPEAT_COMMAND})
            application.run
        end

end
