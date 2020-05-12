########### Ansible AWX install ###########
## Usage: run as sudo                    ##
###########################################

mkdir -p /app/INSTALL_BINARIES
mkdir -p /app/awx/projects
mkdir -p /app/docker/
mkdir -p /app/postgres_data
chmod -R 750 /app

echo "######################################"
echo "##	Installing Docker	  ##"
echo "######################################"
apt update
apt install docker.io -y
systemctl stop docker

cp -r /var/lib/docker /app/
cd /var/lib
mv docker docker_bkp
ln -snf /app/docker docker

systemctl start docker
systemctl enable docker

echo "######################################"
echo "##	   Install Other	  ##"
echo "######################################"
apt install python -y
#apt install python-docker -y
apt install git ansible -y
#apt install libselinux-python -y

echo "######################################"
echo "##	   Clone Git Repo	  ##"
echo "######################################"
cd /app/INSTALL_BINARIES
git clone https://github.com/ansible/awx

echo "######################################"
echo "##    Installing Docker Compose     ##"
echo "######################################"
apt install docker-compose -y
#apt remove -y docker docker-py && pip install docker~=3.7.2
#apt remove -y docker && apt install docker~=3.7.2

# OPTIONAL: install portainer container to manage docker
docker volume create portainer_data

docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer

echo "##################################################################################################"
echo "Review and change some of the below parameters in '/app/INSTALL_BINARIES/awx/installer/inventory'"
echo "postgres_data_dir=/app/postgres_data"
echo "docker_compose_dir=/var/lib/docker/compose/awx"
echo "--------------------------------------------------------------------------------------------------"
cat /app/INSTALL_BINARIES/awx/installer/inventory |grep -v "#" |sort -nr |grep .
echo "##################################################################################################"
echo "cd /app/INSTALL_BINARIES/awx/installer; ansible-playbook -i inventory install.yml"
echo "##################################################################################################"
echo "Portainer URL: http://"`hostname -I | awk '{print $1}'`":9000"
echo "AWX URL: http://"`hostname -I | awk '{print $1}'`""
echo "##################################################################################################"
