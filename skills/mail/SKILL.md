## First Principle

Use local Maildir to let user cowork with agents by mail client

Consider user will sync mailbox, and do this skill in other machine

## Steps

1. Use notmuch or other CLI in PATH to read messages in Maildir @~/Maildir/BOX/
2. For unreplied flagged messages sent by anyone other than agent, send sub-agents on each of them to resolve issue.
3. For sub-agents, set meaningful session name if possible
4. Reply to each message after agent finish their session


## How to Reply

Directly write new RFC-2822 message in @~/Maildir/BOX/ in utf-8 plain text instead of using sendmail(1)

### Header

Context used by user or other sub-agent in the future

- Set "From: <MODEL>@<HOSTNAME>" to mark it is sent by an agent
- If issue context is bound to a host and previous message not specified it, save hostname into "Hostname:"
  So next agent know when to use ssh to resolve issue
- If issue context is bound to an working directory, save it into "Working-Directory:"

### Subject

Summary of solution (Or how sub-agent named its session)

- If sub-agent need user decision (More reply by user), add prefix "[Working] "
- If issue is resolved, add prefix "[Resolved] "

### Body

Contains whole session in ASD-STE100

- Save details (>50 Line or not directly related to summary/decision-making) into attachment(s) and refer them in body
- If diagram/graph is more conveyable, directly use plain/html as Inline Part instead of plain/text
- Append "claude -p <SESSION-ID>" at the end, so user can optionaly continue session in interactive mode


## After Reply

1. Unflagged replied message, and flag newly-added reply to let user know latest progress in mail client
2. Do not report what sub-agents did, just list resolved messages and session id of sub-agents.
