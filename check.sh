#!/bin/bash

check_expire_date() {

certificate_end_date=$(echo | openssl s_client -connect localhost:443 2> /dev/null | openssl x509 -noout -enddate | cut -d '=' -f2)

whiptail --title "Certificate Information" --msgbox "Your self-signed certificate expire at : $certificate_end_date. If is expired, you must regenerate it." 8 78

generate_new

}

generate_new(){

if (whiptail --title "Generate new self-signed certificate" --yesno "Would you generate a new self-signed certificate ?" 8 78); then
    #prevenir d'un redemarrage des services.
    echo "User selected Yes, exit : $?."
    restart_services
else
    echo "User selected No, exit : $?."
    echo "Have a nice day, Wazo team."
fi

}

restart_services(){
if (whiptail --title "Generate new self-signed certificate" --yesno "All services will be restarted, please agree." 8 78); then
    echo "User selected Yes restart services, exit : $?."
    run_renew_certificate $?
else
    echo "User selected No restart services, exit : $?."
    echo "Have a nice day, Wazo team."
fi
}

run_renew_certificate(){
if [ $1 = 0 ]; then
       {
            echo -e "XXX\n50\nAll Wazo Services stopping.\nXXX"
            wazo-service stop all
            echo -e "XXX\n100\nAll Wazo Services stopping... Done.\nXXX"
            sleep 0.7

            echo -e "XXX\n50\nBackup and remove certificates... \nXXX"
            cp /usr/share/xivo-certs/server.{key,crt} /var/backups
            rm /usr/share/xivo-certs/server.{key,crt}
            echo -e "XXX\n100\nBackup and remove certificates... Done.\nXXX"
            sleep 0.7

            echo -e "XXX\n50\nRegenerate self-signed certificate... \nXXX"
            dpkg-reconfigure xivo-certs
            echo -e "XXX\n100\nRegenerate self-signed certificate... Done.\nXXX"
            sleep 0.7

            echo -e "XXX\n50\nRestart Wazo Services... \nXXX"
            xivo-update-config
            wazo-service start all
            echo -e "XXX\n50\nRestart Wazo Services... Done.\nXXX"
            sleep 0.7

        } | whiptail --gauge "Wait Please" 6 60 0

        bye
fi
}

bye(){

certificate_end_date_new=$(echo | openssl s_client -connect localhost:443 2> /dev/null | openssl x509 -noout -enddate | cut -d '=' -f2)

whiptail --title "Congratulation" --msgbox "You have generate new self-signed certificate (New date: $certificate_end_date_new), congratulation. Have a nice day! Wazo Team." 8 78}
}
check_expire_date
