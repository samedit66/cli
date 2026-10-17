class
    FAKETAR_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_SINGLE_COMMAND_APPLICATION
        do
            create application.make (create {FAKETAR_COMMAND})
            application.run
        end

end
