## First Principle

Use local Maildir to let user cowork with agents by mail client

Consider user will sync mailbox, and do this skill in other machine


## Steps

1. Read RFC 2822 message by filename in prompt, end session if it is not found
2  Resolve issue in message. Set meaningful session name if possible
  - If not sure what to do, check "X-Label: " to guess user purpose
  - Check other messages in the same thread if necessary
3. Reply to message after issue resolved or need user decision
4. ONLY report status of reply. Do not summarize it, user track issue ONLY BY YOUR REPLY


## How to Reply

Directly write new RFC 2822 message in @~/Maildir/BOX/ in utf-8 plain text instead of using sendmail(1)

### Header

Context used by user or other agent in the future

- Set "From: <MODEL>@<HOSTNAME>" to mark it is sent by an agent
- Add "Token: " to report token spent
- If issue context is bound to an working directory, save it into "Working-Directory:"

### Subject

Summary of your work

- If you need user decision, add prefix "[Working] "
- If issue is resolved, add prefix "[Resolved] "

### Body

Explain your work in ASD-STE100

- Save details (>50 Line or not directly related to summary/decision-making) into attachment(s) and refer them in body
- If diagram/graph is more conveyable, directly use plain/html as Inline Part instead of plain/text
- Append "claude -p <SESSION-ID>" at the end, so user can optionally continue session in interactive mode


## After Reply

1. Unflagged replied message, and flag newly-added reply to let user know latest progress in mail client
