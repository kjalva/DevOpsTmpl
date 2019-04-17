control.pane.download:
	wget -q --show-progress --https-only --timestamping \
	"https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-apiserver" \
	"https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-controller-manager" \
	"https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kube-scheduler" \
	"https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl"

	chmod +x kube-apiserver kube-controller-manager kube-scheduler kubectl

  	sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/local/bin/

	sudo mkdir -p /var/lib/kubernetes/

	sudo mv ${Ca_Cert_Filename}.pem ${Ca_Cert_Filename}-key.pem ${K8s_Cert_Filename}-key.pem ${K8s_Cert_Filename}.pem \
    ${Service_Account}-key.pem ${Service_Account}.pem \# Service account key needs to be setup
    encryption-config.yaml /var/lib/kubernetes/# encryption-config.yaml file created from controller.encrypt