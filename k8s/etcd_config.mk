etcd.download.pkg: # Download the package
	wget -q --show-progress --https-only --timestamping \
  "https://github.com/coreos/etcd/releases/download/v3.3.9/etcd-v3.3.9-linux-amd64.tar.gz"
  	tar -xvf etcd-v3.3.9-linux-amd64.tar.gz
	sudo mv etcd-v3.3.9-linux-amd64/etcd* /usr/local/bin/

# copy the certificates. ca.pem and etcd specific or certificates generated from cfssl.gencert
#Dummy command below. ETCD_DIR=/etc/etcd
etcd.cert.dir:
	sudo mv  ${Cert_Directory}/*.pem ${ETCD_DIR}/

#Create etcd systemd unit file
etcd.service.systemd:
cat > etcd.service <<"EOF"
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service] # INTERNAL_IP, ETCD_NAME are envrionment/service variables
ExecStart=/usr/bin/etcd --name ETCD_NAME \# TODO find out of ETCD_NAME is to be mentioned
  --cert-file=${ETCD_DIR}/${K8s_Cert_Filename}.pem \ # Certs generated from cfssl.gencert. Alternatively seperate certs for each service is advised.
  --key-file=${ETCD_DIR}/${K8s_Cert_Filename}-key.pem \
  --peer-cert-file=${ETCD_DIR}/${K8s_Cert_Filename}.pem \
  --peer-key-file=${ETCD_DIR}/${K8s_Cert_Filename}-key.pem \
  --trusted-ca-file=${ETCD_DIR}/${Ca_Cert_Filename}.pem \ #CA certs either generate in CFSSL or privately obtained.
  --peer-trusted-ca-file=${ETCD_DIR}/${Ca_Cert_Filename}.pem \
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \
  --listen-peer-urls https://INTERNAL_IP:2380 \
  --listen-client-urls https://INTERNAL_IP:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://INTERNAL_IP:2379 \
  --initial-cluster-token ${Cluster_Token} \ #Cluster name etcd-cluster-prod
  #--initial-cluster etcd1=https://10.0.0.245:2380,etcd2=https://10.0.0.246:2380 \#
  --initial-cluster etcd1=https://${ETCD_CLUSTER1_HOST}:2380,etcd2=https://${ETCD_CLUSTER1_HOST}:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
	INTERNAL_IP=10.0.0.245#Unless already set in environment
	ETCD_NAME=etcd1
	sed -i s/INTERNAL_IP/$INTERNAL_IP/g etcd.service
	sed -i s/ETCD_NAME/$ETCD_NAME/g etcd.service
	sudo mv etcd.service /etc/systemd/system/

etcd.service.start:
	sudo systemctl daemon-reload
	sudo systemctl enable etcd
	sudo systemctl start etcd

# Follow same steps for second cluster.