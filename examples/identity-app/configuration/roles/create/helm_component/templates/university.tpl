apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  annotations:
    fluxcd.io/automated: "false"
  namespace: {{ component_ns }}
spec:
  releaseName: {{ component_name }}-faber
  chart:
    path: {{ chart_path }}/faber
    git: {{ gitops.git_ssh }}
    ref: {{ gitops.branch }}
  values:
    metadata:
      namespace: {{ component_ns }}
      name: {{ component_name }}
    organization:
      name: {{ organization.name }}
    image:
      pullSecret: regcred
      init:
        name: certs-init
        repository: alpine:3.9.4
      agent:
        name: {{ component_name }}
        repository: {{ network.docker.url }}/aries-agents:{{ network.version }}
    service:
      ports: 
        service: {{ endorser.server.httpPort }}
        endpoint: {{ endorser.server.apiPort }}
{% if organization.cloud_provider == 'minikube' %}     
      address: {{ minikube_ip }}
{% else %}      
      address: aab51db0805fd4662be723c6381cbc83-ad707894e3714862.elb.ap-south-1.amazonaws.com
{% endif %}      
      ledger: http://aab51db0805fd4662be723c6381cbc83-ad707894e3714862.elb.ap-south-1.amazonaws.com:15010
      genesis: http://aab51db0805fd4662be723c6381cbc83-ad707894e3714862.elb.ap-south-1.amazonaws.com:15010/genesis
    vault:
      address: {{ vault.url }}
      serviceAccountName: {{ service_account }}
      authPath: {{ auth_method_path }}
      endorserName: {{ endorser.name }}
      role: ro
    storage:
      size: 128Mi
      className: {{ organization.name }}-{{ organization.cloud_provider }}-storageclass
    proxy:
{% if organization.cloud_provider == 'minikube' %}     
      provider: "minikube"
{% else %}      
      provider: "ambassador"
{% endif %}
