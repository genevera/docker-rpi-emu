apt-get install hostapd isc-dhcp-server cron -y
apt-get install python-pip python-virtualenv -y
update-rc.d -f isc-dhcp-server remove
update-rc.d -f hostapd remove

echo "DAEMON_CONF=\"/etc/hostapd/hostapd.conf\"" >> /etc/default/hostapd

MYPATH="/root"
cd $MYPATH
git clone https://github.com/HotBlackRobotics/raspberry-autowifi
cd raspberry-autowifi
virtualenv env && source env/bin/activate && pip install -r requirements.txt
cp -f $MYPATH/raspberry-autowifi/configs/interfaces /etc/network/interfaces
cp -f $MYPATH/raspberry-autowifi/configs/dhcpd.conf /etc/dhcp/dhcpd.conf
cp $MYPATH/raspberry-autowifi/configs/hostapd.conf /etc/hostapd/

crontab -l > mycron
echo "@reboot $MYPATH/raspberry-autowifi/env/bin/python /root/raspberry-autowifi/scripts/autowifi.py >> /var/log/wifi_auto.log" >> mycron
crontab mycron
rm mycron
update-rc.d cron defaults

echo "[Service]" >> /lib/systemd/system/networking.service.d/network-pre.conf
echo "TimeoutStartSec=1" >> /lib/systemd/system/networking.service.d/network-pre.conf
