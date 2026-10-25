note
    description: "Entry points for the greet example application."
    author: "samedit66"
    email: "samedit66@yandex.ru"

class GREET_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
            -- Run the example application.
        local
            application: CLI_APPLICATION
        do
            create application.make_single_command ("greet", create {GREET_COMMAND})
            application.run
        end

end
