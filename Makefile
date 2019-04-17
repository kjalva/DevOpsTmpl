cfssl.setup:
	wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
	chmod +x cfssl_linux-amd64
	sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

cfssl.json.setup:
	wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
	chmod +x cfssljson_linux-amd64
	sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

cfssl.ca.config:
	mkdir -p ${cfssl_dir}/cert #TODO: Confirm the dir for the certificates to be created
	cd cert
	echo '{
  		"signing": {
    		"default": {
     			 "expiry": "8760h"
    		},
    		"profiles": {
      			"kubernetes": {
        			"usages": ["signing", "key encipherment", "server auth", "client auth"],
        			"expiry": "8760h"
      			}
    		}
  		}
	}' > ca-config.json

cfssl.ca.csr:
	check_move_cfssl_dir.sh #TODO
	echo '{
  		"CN": ${CN},# Common name for the certificate
  		"key": {
    		"algo": "rsa",
    		"size": 2048
  		},
  		"names": [
    		{
      			"C": ${CSR_COUNTRY}, #Country
      			"L": ${CSR_State}, #State
      			"O": ${CSR_CITY}, #City
      			"OU": ${CSR_ORG}, #Organisation
      			"ST": ${CSR_ORG_UNIT} #Organisation Unit
    		}
  		]
	}' > ca-csr.json

cfssl.config.client: # Used to be passed as argument for gencert for root ca in cfssl remote server
	echo '{
  		"signing": { # The signing section contains signing profiles for generating different kinds of certificates
    		"profiles": {
      			"client-server": { # This would be the profile name 
        			"auth_remote": {
          			"auth_key": "client",
          			"remote": "ca" # mapped to remotes section
        			}
      			}
    		}
  		},
  		"auth_keys": { # Should be implemented using init containers and k8s secrets
    		"client": {
      			"type": "standard",
      			"key": "D08E2AD3153827496ADDA6FB104624B2" #List of keys used by clients to access the service
    		}
  		},
  		"remotes": {
    		"ca": "0.0.0.0:8080" # TODO: Verify the remotes values
  		}
	}' > config-client.json

cfssl.initca.csr:
	echo '{
  		"CN": "My Personal CA",# TODO: Verify CN value
  		"key": {
    		"algo": "rsa",
    		"size": 2048
  		},
  		"ca": {
    		"expiry": "17520h"
  		}
	}' > csr_initca.json

# Generate admin certificates. Copy the certificates generated from below command to specific folder.
cfssl.gencert:
	 cfssl gencert \
      -remote=pki.${CFSSL_REMOTE_SERVER}:8888 \ # CFSSL remote server URL. Localhost if run locally
      -profile=${PROFILE}  - \
    | cfssljson -bare ${K8s_Cert_Filename} #Generated file name. Files generated would be ca.pem, ca-key.pem

cfssl.server.initca.gencert:# To be executed in cfssl server
	cfssl gencert -initca csr_initca.json | cfssljson -bare ${cfssl_server_cert_filename}

cfssl.server.serve:# To be executed in cfssl server
	cfssl serve -address=0.0.0.0 -port=8080 -config=config.json -ca=${cfssl_server_cert_filename}.pem -ca-key=${cfssl_server_cert_filename}-key.pem

# running the below command should result in 3 files. ca.pem, ca-key.pem and ca.csr. 
#ca.pem generated from below command can be stored and used with hosts mentioned in ca-csr.json files
cfssl.client.initca.gencert:# To be executed in while setting up kubernetes
	cfssl gencert -initca ca-csr.json | cfssljson -bare ${ca_cert_filename}