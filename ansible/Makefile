SHELL := /usr/bin/env bash 

setup:
	curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
	python3 /tmp/get-pip.py --user --upgrade &&	rm /tmp/get-pip.py
	sudo apt-get install -yq python3-dev python3-distutils python3-venv libvirt-dev pkg-config
	python3.10 -m venv ~/.virtualenvs/ansible
	source ~/.virtualenvs/ansible/bin/activate && \
		python3 -m pip install --upgrade pip && \
		pip3 install -r requirements.txt && \
		ansible-galaxy install -r requirements.yml

inventory:
	ansible-inventory --inventory libvirt-plugin.yml --list

check:
	ansible -i libvirt-plugin.yml all -m ping --limit k8s-*

ping:
	ansible -i inventory/k8s-cluster/inventory.ini all -m ping

truncate:
	ansible -i inventory/k8s-cluster/inventory.ini all -m command -a 'truncate -s 0 /var/log/daemon.log' --become

facts:
	ansible -i inventory/k8s-cluster/inventory.ini nodes[2] -m setup -a 'filter=ansible*'

kubernetes:
	ansible-playbook --inventory libvirt-plugin.yml --limit k8s-master* master.yml
	ansible-playbook --inventory libvirt-plugin.yml --limit k8s-worker* worker.yml

k3s-cluster:
	ansible-playbook -i inventory/k3s-ha/inventory.ini playbooks/k8s/k3s.yml

clean-known-hosts:
	@seq 1 3 | xargs -I% -n1 ssh-keygen -f ~/.ssh/known_hosts -R k8s-master%
	@seq 1 3 | xargs -I% -n1 ssh-keygen -f ~/.ssh/known_hosts -R k8s-node%

k8s-cluster:
	ansible-playbook -i inventory/k8s-cluster/inventory.ini playbooks/k8s/kubeadm.yml