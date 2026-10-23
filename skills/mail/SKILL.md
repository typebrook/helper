1. Use notmuch or other CLI in PATH to read messages in Maildir @~/Maildir/BOX/
2. For each unreplied flagged message, send subagents on each of them to resolve
3. Reply to each flagged messages after agent finish their session
  - Headers with context for next working agent
  - Subject for your solution (Or how you named this session)
  - Body for the summary of session in ASD-STE100
    * Save details (>50 Line or not directly related to user respond) into attachment(s) and refer them in body
  - Consider user will reply to latest message, and flag them as the following issues
  - Consider user will sync mailbox, and do this skill in other machine
    * Save hostname into header if issue context is bound to a host, and previous message not specified it.
      So next agent know when to use ssh to resolve issue
