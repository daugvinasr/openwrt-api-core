## uhttpd

Tai ko mes pas tave api nesam padaręs, kad kai pakeiti/išsaugai konfigūraciją, niekas nepasako procd, kad perkrautų init skriptą
Tai dabar padarius kokius nors pakeitimus teoriškai pas tave nieko neįvyktų apart to, kad išsaugotų konfigūracija
Siūlyčiau pasikurti dabar atskirą controllerį ir mėginsi paleisti paprastą procesą
Bandysim paleisti mqtt broker'į
Jo konfigūracija turėtų būti saugoma mosquitto config faile
NEpamenu jo struktūros, tai teks pasižiūrėti tam kitam FW kaip jisai veikia
Tiksliau kokias vertes ten rašo
Ką tau reikės padaryti, kad priimtų bent šias tris vertes:
enable host port
Nice to have būtų tls sertifikatai, kad secure naudotų connection'ą
Kai užupdatini/sukurti sekciją iš esmės turėtum perkrauti uci
Bet tau kažko custom nereiėks daryti, šiaip jau ten viskas padarya
Tik deja reikės susirasti 

while inotifywait -r -e modify,create,delete,move ./uhttpd; do
    sshpass -p admin01 rsync -avz /home/studentas/Documents/uhttpd root@192.168.1.1:/usr/lib/lua/ --delete
done

while inotifywait -r -e modify,create,delete,move /usr/lib/lua/uhttpd; do
    /etc/init.d/uhttpd restart
done

logread -f