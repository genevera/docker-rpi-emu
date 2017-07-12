echo "================ Upgrade env ================"
apt-get update
apt-get upgrade -y
apt-get install git -y

echo "================ Installing ROS Indigo ================"
sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
apt-get update
apt-get install ros-indigo-ros-base -y
apt-get install ros-indigo-rosbridge-suite ros-indigo-rosserial-server -y
echo "================ ROS Indigo Installed ================"
