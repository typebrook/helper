# IMAP/SMTP settings
set imap_user = "typebrook@gmail.com"
set imap_pass = `pass google/imap_for_typebrook`
set smtp_url = "typebrook@gmail.com"
set smtp_pass = "$imap_pass"

set ssl_starttls = yes 
set ssl_force_tls = yes

# Set mailboxes
set folder = "imaps://imap.gmail.com/"
set spoolfile = "+INBOX"
set postponed = "+[Gmail]/Drafts"
set record = "+[Gmail]/Sent Mail"
set trash = "+[Gmail]/Trash"
