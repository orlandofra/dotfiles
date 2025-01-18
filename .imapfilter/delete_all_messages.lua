options.timeout = 120
options.subscribe = true

account = IMAP {
    server = 'mail.autistici.org',
    username = 'vacci@canaglie.org',
}

inbox = account.INBOX

messages = inbox:select_all()
messages:delete_messages()

inbox:expunge()
