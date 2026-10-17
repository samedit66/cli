class CLI_FAILURE
        -- Shared fatal diagnostic and process termination.

feature {NONE} -- Termination

    fail (a_message: STRING_32; a_exit_code: INTEGER)
            -- Print `a_message' to standard error and terminate the process.
            -- Never return; no exception is raised and no rollback is performed.
        require
            nonzero_exit_code: a_exit_code /= 0
        local
            l_exceptions: EXCEPTIONS
        do
            io.error.put_string_32 (a_message + "%N")
            io.error.flush
            create l_exceptions
            l_exceptions.die (a_exit_code)
        ensure
            never_returns: False
        end

end
