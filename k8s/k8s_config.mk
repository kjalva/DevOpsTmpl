# Ensure Ca certificates and generated certificates from cfssl.gencert is moved to the k8s api server
k8s.pkg.download:
	curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-apiserver
	curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-controller-manager
	curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-scheduler
	curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl
	chmod +x kube*
	sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/