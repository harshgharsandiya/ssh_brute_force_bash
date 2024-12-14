# Brute Force SSH Login Simulator
---

## **Overview**
This tool brute force ssh attack from given username and password list using bash script.

> **Disclaimer**: This tool is only for educational purposes. Don't use this tool without proper authorization.

---

## Working
- Command line argument : `<target_id> <username> <password_list>`
- Use `sshpass` to attempt non-interactive SSH logins.
- If password found, this tool let you know.

---

## **Requirements**
- **OpenSSH Server** (configured on target)
- **sshpass** (install on your machine)

## **Usage**
 
1. Clone Repo
```bash
git clone https://github.com/harshgharsandiya/ssh-brute-force-bash.git
cd ssh-brute-force-bash
```

2. Run 
```bash
chmod +x ssh_brute_force.sh
./ssh_brute_force.sh <target_ip> <username> <password_list>
```

