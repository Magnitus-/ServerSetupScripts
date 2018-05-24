
INITIAL_CLUSTER=""
INDEX=$((0))

for ELEMENT in $INVENTORY
do
    if [ -z "$INITIAL_CLUSTER" ]; then
        INITIAL_CLUSTER="etcd${INDEX}=https://${ELEMENT}:2380"
    else
        INITIAL_CLUSTER="${INITIAL_CLUSTER},etcd${INDEX}=https://${ELEMENT}:2380"
    fi
    INDEX=$((INDEX+1))
done

#TODO: Make compatible arm64 etcd image
#https://github.com/coreos/etcd/releases?after=v3.2.7
cat >/etc/kubernetes/manifests/etcd.yaml <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    component: etcd
    tier: control-plane
  name: etcd_${MASTER_ID}
  namespace: kube-system
spec:
  containers:
  - name: etcd
    image: k8s.gcr.io/etcd-amd64:3.1.10
    command: ["etcd"]
    args:
    - --data-dir=/var/lib/etcd
    - --listen-client-urls https://localhost:2379
    - --advertise-client-urls https://localhost:2379
    - --listen-peer-urls https://localhost:2380
    - --initial-advertise-peer-urls https://localhost:2380
    - --cert-file=/certs/server.pem
    - --key-file=/certs/server-key.pem
    - --client-cert-auth
    - --trusted-ca-file=/certs/ca.pem
    - --peer-cert-file=/certs/peer.pem
    - --peer-key-file=/certs/peer-key.pem
    - --peer-client-cert-auth
    - --peer-trusted-ca-file=/certs/ca.pem
    - --initial-cluster ${INITIAL_CLUSTER}
    - --initial-cluster-token my-etcd-token
    - --initial-cluster-state new
    livenessProbe:
      httpGet:
        path: /health
        port: 2379
        scheme: HTTP
      initialDelaySeconds: 15
      timeoutSeconds: 15
    env:
    - name: PUBLIC_IP
      valueFrom:
        fieldRef:
          fieldPath: status.hostIP
    - name: PRIVATE_IP
      valueFrom:
        fieldRef:
          fieldPath: status.podIP
    - name: PEER_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    volumeMounts:
    - mountPath: /var/lib/etcd
      name: etcd
    - mountPath: /certs
      name: certs
hostNetwork: true
volumes:
- hostPath:
    path: /var/lib/etcd
    type: DirectoryOrCreate
    name: etcd
- hostPath:
    path: /etc/kubernetes/pki/etcd
    name: certs
EOF