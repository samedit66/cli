class
    ARC_APPLICATION

create
    make

feature {NONE} -- Entry point

    make
        local
            application: CLI_APPLICATION
        do
            create application.make ("arc", "Archive interface demonstration; reports values without archive operations")
            application.add_command (create {ARC_ROOT_COMMAND})
            application.add_command (create {ARC_PACK_COMMAND})
            application.add_command (create {ARC_UNPACK_COMMAND})
            application.add_command (create {ARC_LIST_COMMAND})
            application.add_command (create {ARC_LIST_TREE_COMMAND})
            application.add_command (create {ARC_INFO_COMMAND})
            application.add_command (create {ARC_VERIFY_COMMAND})
            application.add_command (create {CLI_HELP_COMMAND}.make (application))
            application.run
        end

end
