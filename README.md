# OpenPGP Web Key Directory Service (WKS) with Sieve
A bash script and a sieve script that implements an OpenPGP Web Key Directory Service.

## Set-up
1. `apt install swaks gpg gpg-wks-server dovecot-core dovecot-imapd dovecot-lmtpd dovecot-managesieved dovecot-sieve`. swaks is used for notifications of script success or failure. You may use another mailer if desired, mutatis mutandis.
2. Set up Dovecot according to your needs using your usual practices (use an online guide if needed). Set up sieve with Dovecot. 
3. Put the bash script (`process-wks-request.script`) somewhere accessible to Dovecot and make it executable, e.g., `/usr/local/bin`.
4. Put the sieve script (`wks.sieve`) in your global sieve scripts and compile/enable it. Configure Dovecot to use it.

Example Dovecot 2.4 config (90.sieve.conf):
```
...

sieve_plugins {
  sieve_imapsieve =yes
  sieve_extprograms = yes
}
sieve_extensions {
  mboxmetadata = yes
  editheader = yes
  servermetadata = yes
  imap4flags = yes
  spamtest = yes
  spamtestplus = yes
  virustest = yes
  imapsieve = yes
}
sieve_global_extensions {
  vnd.dovecot.pipe = yes
  vnd.dovecot.environment = yes
  vnd.dovecot.execute = yes
}
sieve_pipe_bin_dir = /usr/local/bin
sieve_execute_bin_dir = /usr/local/bin

# Perform actions for WKS requests.
sieve_script wks {
  type = before
  path = /mnt/mail/home/vmail/sieve/global/wks.sieve
}

...
```

## Usage

To register a key with the WKS, send an unencrypted message to the submission-address; wkd-submission@<your-domain>.com with your public key as an attachment (in .asc format). Dovecot/Sieve will recognize it as a WKS request, and pipe it to the script. The script will use gpg-wks-server to register the key. Notifications and logging (back to Devecot) are issued on success and failure both to the requesting user and to an admin. Adjust the values as needed for your setup. The script is commented to help you understand what is going on. At the bottom is a commented section showing the method I had tried before and never got to work, the method you can find in various places on the Internet. Fixing that was the rationale for this script. I hope it's helpful. Feel free to make improvements.
