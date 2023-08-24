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
# TODO: uninstall old versions
if [ "$os" == "ubuntu" ]; then
    # TODO: add verification for docker package repo
        for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update
        sudo apt install docker-ce docker-ce-cli containerd.io -y
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