FROM python:3.6.5-slim-stretch

ENV ANSIBLE_USER=admin
ENV PRIVATE_SSH_KEY=/opt/keys/id_rsa
ENV INVENTORY_DESTINATION=/opt/inventory/deployment
ENV KUBESPRAY_DESTINATION=/opt/kubespray
ENV MASTERS_COUNT=3

RUN apt-get update && apt-get install -y openssh-client sshpass git

WORKDIR /opt

RUN git clone https://github.com/kubernetes-sigs/kubespray.git

RUN pip install -r $KUBESPRAY_DESTINATION/requirements.txt

COPY kubespray_commands /opt/kubespray_commands

RUN pip install /opt/kubespray_commands

WORKDIR $KUBESPRAY_DESTINATION

ENTRYPOINT [""]

CMD ["kubecmds", "--help"]