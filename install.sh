#!/bin/bash

BOOTSTRAP="4.3.1"
FONTAWESOME="4.7.0"
JQUERY="3.3.1"
POPPER="1.14.7"
SCRIPTNAME=$(basename "$0")
SCRIPTPATH=$(dirname "$(readlink -f "$0")")
CONFIGFOLDER="config"
CONFIGFILE="web.ini"
WEBDIR="$SCRIPTPATH/web"
TMPDIR="$WEBDIR/tmp"
STEPS=11
STEP=1

if [ "$EUID" -ne 0 ]; then
    read -r -d '' NOROOT <<EOF
Heya! To install easywall-web you need to have a privileged user.
So you can try these:

# sudo -H bash $SCRIPTNAME
or
# su root -c "$SCRIPTNAME"
EOF
    echo "$NOROOT"
    exit 1
fi

# Step 1
echo "" && echo "($STEP/$STEPS) install required operating system packages" && ((STEP++))
apt update
apt -y install python3 python3-pip uwsgi uwsgi-plugin-python3 wget unzip

# Step 2
echo "" && echo "($STEP/$STEPS) install required python 3 packages using pip" && ((STEP++))
pip3 install -r requirements.txt
pip3 install "$SCRIPTPATH"

# Step 3
echo "" && echo "($STEP/$STEPS) creating configuration file from example" && ((STEP++))
cp "$SCRIPTPATH"/"$CONFIGFOLDER"/"$CONFIGFILE".example "$SCRIPTPATH"/"$CONFIGFOLDER"/"$CONFIGFILE"

# Step 4
echo "" && echo "($STEP/$STEPS) installing 3rd party files for easywall-web" && ((STEP++))
mkdir "$TMPDIR" && cd "$TMPDIR" || exit 1

# Bootstrap
wget -q --show-progress "https://stackpath.bootstrapcdn.com/bootstrap/$BOOTSTRAP/css/bootstrap.min.css"
cp "bootstrap.min.css" "$WEBDIR/static/css/"
wget -q --show-progress "https://stackpath.bootstrapcdn.com/bootstrap/$BOOTSTRAP/js/bootstrap.min.js"
cp "bootstrap.min.js" "$WEBDIR/static/js/"

# Font Awesome
wget -q --show-progress "https://fontawesome.com/v$FONTAWESOME/assets/font-awesome-$FONTAWESOME.zip"
unzip -q "font-awesome-$FONTAWESOME.zip"
cp -r "font-awesome-$FONTAWESOME/css/"* "$WEBDIR/static/css/"
cp -r "font-awesome-$FONTAWESOME/fonts/"* "$WEBDIR/static/fonts/"

# JQuery Slim (for Bootstrap)
wget -q --show-progress "https://code.jquery.com/jquery-$JQUERY.slim.min.js"
cp jquery-$JQUERY.slim.min.js "$WEBDIR/static/js/"

# Popper (for Bootstrap)
wget -q --show-progress "https://unpkg.com/popper.js@$POPPER/dist/umd/popper.min.js"
cp popper.min.js "$WEBDIR/static/js/"

cd "$SCRIPTPATH" || exit 1
rm -rf "$TMPDIR"

# Step 5
echo "" && echo "($STEP/$STEPS) creating easywall-web system user and creating permission for file modification" && ((STEP++))
adduser --system easywall
adduser easywall easywall

# Step 6
echo "" && echo "($STEP/$STEPS) setting folder permission for easywall-web application user" && ((STEP++))
chown -R easywall:easywall "$WEBDIR"
chown -R easywall:easywall "$SCRIPTPATH"/"$CONFIGFOLDER"
chmod -R 750 "$SCRIPTPATH"/"$CONFIGFOLDER"

# Step 7
echo "" && echo "($STEP/$STEPS) installing systemd process for easywall-web" && ((STEP++))
function installDaemon() {
    SERVICEFILE="/lib/systemd/system/easywall-web.service"
    read -r -d '' SERVICECONTENT <<EOF
[Unit]
Description=easywall Web - The IPTables Interface WebInterface
Wants=network-online.target
After=syslog.target time-sync.target network.target network-online.target

[Service]
ExecStart=/bin/bash easywall_web.sh
WorkingDirectory=${SCRIPTPATH}
Restart=always
RestartSec=10
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=easywall-web
User=easywall
Group=easywall

[Install]
WantedBy=multi-user.target
EOF
    touch $SERVICEFILE
    echo "$SERVICECONTENT" >$SERVICEFILE
    systemctl daemon-reload
    systemctl enable easywall-web
}

read -r -n1 -p "Do you want to install easywall-web as a Daemon? [y,n]" DAEMON
case $DAEMON in
y | Y) printf "\\ninstalling service ...\\n" && installDaemon ;;
n | N) printf "\\nNot installing Daemon.\\n" ;;
*) printf "\\nNot installing Daemon.\\n" ;;
esac

# Step 11
echo "" && echo "($STEP/$STEPS) Please set a password for easywall Web" && ((STEP++))
/usr/bin/python3 core/passwd.py
