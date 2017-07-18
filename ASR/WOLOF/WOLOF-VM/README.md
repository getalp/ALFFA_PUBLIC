# kaldi_wolof_asr

Virtual Machine Vagrantfile for ALFFA_PUBLIC WOLOF ASR experiment

This is the Vagrantfile and some modified scripts to implement a Vagrant virtual machine
that can run the WOLOF African ASR experiment from [ALFFA_PUBLIC](https://github.com/besacier/ALFFA_PUBLIC/tree/master/ASR/WOLOF)

To run it, first we assume you have installed the latest versions of Vagrant and VirtualBox.
Also assume you've cloned this GitHub repository into a local folder and have the handful of scripts
and Vagrantfile in the working directory.

 * Run the shell command `vagrant up`
 * Watch [lots of output](https://github.com/riebling/FONGBE-vm/wiki/vagrant-up-output) as Vagrant provisions the virtual machine
 * When it finishes, assuming it succeeded, ssh into the VM with `vagrant ssh`
 * change to the WOLOF folder in the home directory - `cd WOLOF`
 * Run the experiment - `./run.sh`
 * Watch [lots of output](https://github.com/riebling/FONGBE-vm/wiki/sample-output) and see scores at the end
