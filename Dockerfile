FROM python:3.6.5-slim-stretch

RUN apt-get update && apt-get install -y openssh-client sshpass
RUN pip install ansible

ENV ANSIBLE_USER='root'
ENV ANSIBLE_INVENTORY='inventory'
ENV ANSIBLE_PLAYBOOK='k8_cluster_ha'
ENV ANSIBLE_HOST_KEY_CHECKING='False'

COPY playbooks /opt/playbooks
COPY roles /opt/roles

COPY image/entrypoint.py /opt/entrypoint.py

RUN mkdir -p /opt/inventories && mkdir -p /opt/keys

ENTRYPOINT ["/opt/entrypoint.py"]