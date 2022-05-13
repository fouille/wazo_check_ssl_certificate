#!/bin/bash

check_expire_date() {

certificate_end_date=$(openssl s_client -connect localhost:443 2> /dev/null | openssl x509 -noout -enddate | cut -d '=' -f2)

whiptail --title "Certificate Information" --msgbox "Your certificate expire at : "$certificate_end_date". If is expired, you must regenerate it." 8 78

generate_new

}

generate_new(){

if (whiptail --title "Generate new certificate" --yesno "Would you generate a new certificate ?" 8 78); then
    #prevenir d'un redemarrage des services.
    echo "User selected Yes, exit : $?."
else
    echo "User selected No, exit : $?."
fi

}


check_expire_date
