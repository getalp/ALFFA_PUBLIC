# -*- mode: ruby -*-
# vi: set ft=ruby

Vagrant.configure("2") do |config|

    # Default provider is VirtualBox!
    # If you want AWS, you need to populate and run e.g.
    #   . aws.sh; vagrant up --provider aws
    # Make sure you don't check in aws.sh (maybe make a copy with your "secret" data)
    # Before that, do
    #   vagrant plugin install vagrant-aws; vagrant plugin install vagrant-sshfs
    config.vm.box = "ubuntu/trusty64"
    config.vm.synced_folder ".", "/vagrant", :mount_options => ["dmode=777", "fmode=777"]
    config.vm.hostname = "vagrant-kaldi-african"

    config.vm.provider "virtualbox" do |vbox|
      config.ssh.forward_x11 = true

      # enable (uncomment) this for debugging output
      #vbox.gui = true

      # host-only network on which web browser serves files
#      config.vm.network "private_network", ip: "192.168.56.101"

      vbox.cpus = 8
      vbox.memory = 8192
    end

    config.vm.provider "aws" do |aws, override|

      aws.tags["Name"] = "Kaldi African"
      aws.ami = "ami-663a6e0c" # Ubuntu ("Trusty") Server 14.04 LTS AMI - US-East region
      aws.instance_type = "m3.xlarge"

      override.vm.synced_folder ".", "/vagrant", type: "sshfs", ssh_username: ENV['USER'], ssh_port: "22", prompt_for_password: "true"

      override.vm.box = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

      # it is assumed these environment variables were set by ". env.sh"
      aws.access_key_id = ENV['AWS_KEY']
      aws.secret_access_key = ENV['AWS_SECRETKEY']
      aws.keypair_name = ENV['AWS_KEYPAIR']
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = ENV['AWS_PEM']

      aws.terminate_on_shutdown = "true"
      aws.region = ENV['AWS_REGION']

      # https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#SecurityGroups
      # Edit the security group on AWS Console; Inbound tab, add the HTTP rule
      aws.security_groups = "launch-wizard-1"

      #aws.subnet_id = "vpc-666c9a02"
      aws.region_config "us-east-1" do |region|
        #region.spot_instance = true
        region.spot_max_price = "0.1"
      end

      # this works around the error from AWS AMI vm on 'vagrant up':
      #   No host IP was given to the Vagrant core NFS helper. This is
      #   an internal error that should be reported as a bug.
      #override.nfs.functional = false
    end

  config.vm.provision "shell", inline: <<-SHELL
    sudo apt-get update -y
    sudo apt-get upgrade

    if grep --quiet vagrant /etc/passwd
    then
      user="vagrant"
    else
      user="ubuntu"
    fi

    sudo apt-get install -y git make automake libtool autoconf patch subversion fuse\
       libatlas-base-dev libatlas-dev liblapack-dev sox openjdk-6-jre libav-tools g++\
       zlib1g-dev libsox-fmt-all apache2 sshfs cmake libboost-all-dev

    # If you wish to train EESEN with a GPU machine, uncomment this section to install CUDA
    # also uncomment the line that mentions cudatk-dir in the EESEN install section below
    #cd /home/${user}
    #wget -nv http://speechkitchen.org/vms/Data/cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
    #dpkg -i cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
    #rm cuda-repo-ubuntu1404-7-5-local_7.5-18_amd64.deb
    #apt-get update                                                                  
    #apt-get remove --purge xserver-xorg-video-nouveau                           
    #apt-get install -y cuda

    # get the corpus data - in this case FONGBE experiment
    cd /vagrant
    svn co https://github.com/besacier/ALFFA_PUBLIC/trunk/ASR/FONGBE
    cd /home/${user}
    ln -s /vagrant/FONGBE .

    # temporary: replace scripts with versions that work for VM
    cp /vagrant/*.sh /vagrant/FONGBE/kaldi-scripts
    cp /vagrant/path.sh /vagrant/FONGBE

    # African Kaldi scripts rely on /bin/sh but Ubuntu points that to dash
    # undo this
    rm /bin/sh
    ln -s /bin/bash /bin/sh

    # install KenLM
#    cd /home
#    git clone https://github.com/kpu/kenlm
#    cd kenlm
#    mkdir -p build && cd build
#    cmake ..
#    make -j `lscpu -p|grep -v "#"|wc -l`

    # install Kaldi - normally in /home/${user}/kaldi-trunk
    cd /home/${user}
    git clone https://github.com/kaldi-asr/kaldi kaldi-trunk
    cd kaldi-trunk/tools
    make -j `lscpu -p|grep -v "#"|wc -l`

    cd /home/vagrant/kaldi-trunk/src   
    ./configure # --shared --cudatk-dir=/opt/nvidia/cuda
    make depend
    make -j `lscpu -p|grep -v "#"|wc -l`

    # Turn off release upgrade messages
    sed -i s/Prompt=lts/Prompt=never/ /etc/update-manager/release-upgrades
    rm -f /var/lib/ubuntu-release-upgrader/*
    /usr/lib/ubuntu-release-upgrader/release-upgrade-motd
    
    # Silence error message from missing file
    touch /home/${user}/.Xauthority 

    # Provisioning runs as root; we want files to belong to '${user}' e.g. vagrant
    chown -R ${user}:${user} /home/

  SHELL
end

# always monitor watched folder
  Vagrant.configure("2") do |config|
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    if grep --quiet vagrant /etc/passwd
    then
      user="vagrant"
    else
      user="ubuntu"
    fi

    rm -rf /var/run/motd.dynamic
SHELL
  end
