# Check if OS is Ubuntu-based, Fedora-based, RHEL-based, or Arch-based

# detect ubuntu
if grep -qs "ubuntu" /etc/os-release; then
	os="ubuntu"
# detect debian
elif grep -qs "debian" /etc/os-release; then
    os="debian"
# detect RHEL and it's derivatives
elif grep -qs "rhel" /etc/os-release; then
    os="rhel"
# detect oracle linux
elif grep -qs "oracle" /etc/os-release; then
    os="rhel"
# detect fedora
elif grep -qs "fedora" /etc/os-release; then
    os="fedora"
# detect arch
elif grep -qs "arch" /etc/os-release; then
    os="arch"
else
    echo "Unknown OS"
    exit
fi

# Color codes
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Usage: color_text "text" color
color_text() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}${NC}"
}

printf "Detected: %s\n" "$os"

color_text "STEP 1: Install Docker" "$ORANGE"
# Installation steps provided by Digital Ocean https://www.digitalocean.com/community/tutorial-collections/how-to-install-and-use-docker
# as well as the official docker documentation https://docs.docker.com/engine/install/
if [ "$os" == "ubuntu" ]; then
    # TODO: fix ubuntu
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    # find the version of ubuntu and store it in a variable
    ubuntu_codename=$(cat /etc/os-release | grep -oP '(?<=VERSION_CODENAME=")[^"]*')
    printf "Ubuntu version: %s\n" "$ubuntu_codename"
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu "$ubuntu_codename" stable"
    sudo apt install docker-ce
    sudo systemctl enable --now docker
    sudo usermod -aG docker ${USER}
elif [ "$os" == "debian" ]; then
    # TODO: finish debian
    sudo apt update
    sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common

elif [ "$os" == "rhel" ]; then
    sudo dnf check-update
    sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker ${USER}
elif [ "$os" == "fedora" ]; then
    sudo dnf -y install dnf-plugins-core
    sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    sudo dnf install docker-ce docker-ce-cli containerd.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker ${USER}
elif [ "$os" == "arch" ]; then
    sudo pacman -S --noconfirm docker
    sudo systemctl enable --now docker
    sudo usermod -aG docker ${USER}
fi

color_text "STEP 2: Install Portainer Agent" "$ORANGE"

# run /bin/bash on a docker container to test if docker is working with library/ubuntu
# docker run -it ubuntu /bin/bash