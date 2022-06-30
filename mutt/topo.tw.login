# IMAP/SMTP settings
set folder = "imaps://pham@mail.topo.tw:993/"
set imap_pass = `pass pham@topo.tw`
set smtp_url = "smtp://pham@mail.topo.tw:587"
set smtp_pass = "$imap_pass"

# Identify meself
set from = "pham@topo.tw"
set realname = "謝晉凡 Hsieh Chin Fan"
set signature="$SETTING_DIR/mutt/.signature"
set pgp_use_gpg_agent=yes
set crypt_use_gpgme=yes
set pgp_timeout=300
set pgp_sign_as=6DD8C14A # replace 6DD8C14A with your gpg key id

# Basic Mailbox
set spoolfile = "+INBOX"
set mbox= "+mbox"
set move = yes
set record = "+Sent"
set trash = "+Trash"
set postponed = "+Drafts"

# Sidebar
mailboxes =INBOX =mbox "+------ Watch ------" =pay =osm =keep "+---- Processed ----" =Sent =Trash =Drafts
