worker.cluster.config:
	kubectl config \
	set-cluster cluster-${CLUSTER_NAME} \
	--server=https://${MASTER_URL} \
	--certificate-authority=${CA_PATH} \
	--embed-certs=true

    # configure user details

	kubectl config \
	set-credentials admin-${CLUSTER_NAME} \
	--certificate-authority=${CA_PATH} \
	--client-key=${ADMIN_KEY_PATH} \
	--client-certificate=${ADMIN_CERT_PATH} \
	--embed-certs=true

    # configure context details

	kubectl config \
	set-context ${CLUSTER_NAME} \
	--cluster=cluster-${CLUSTER_NAME} \
	--user=admin-${CLUSTER_NAME}

    # switch to desired context

	kubectl config \
	use-context ${CLUSTER_NAME}