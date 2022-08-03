#!/usr/bin/env bash

# Creates sealed secret YAML to go into oc project openldap with these LDAP passwords:
if [[ -z ${LDAP_ADMIN_PASSWORD} ]] || [[ -z ${LDAP_CONFIG_PASSWORD} ]] ; then
  echo "Please provide strong passwords for BOTH environment variables LDAP_ADMIN_PASSWORD and LDAP_CONFIG_PASSWORD."
  exit 1
fi

LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD}
LDAP_CONFIG_PASSWORD=${LDAP_CONFIG_PASSWORD}

# These two are either provided or default to "sealed-secrets"
SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml in namespace "openldap"
oc create secret generic openldap -n openldap \
   --from-literal LDAP_ADMIN_PASSWORD=${LDAP_ADMIN_PASSWORD} \
   --from-literal LDAP_CONFIG_PASSWORD=${LDAP_CONFIG_PASSWORD} \
   --dry-run=client -o yaml > delete-ldap-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n openldap --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ldap-secret.yaml > ldap-secret.yaml

# NOTE, do not push delete-ldap-secret.yaml into git!
rm delete-ldap-secret.yaml
