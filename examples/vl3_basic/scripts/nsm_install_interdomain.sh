#!/bin/bash

HUB=${HUB:-tiswanso}
TAG=${TAG:-vl3_api_rebase}

INSTALL_OP=${INSTALL_OP:-apply}

sdir=$(dirname ${0})
#echo "$sdir"

NSMDIR=${NSMDIR:-${sdir}/../../../../networkservicemesh}
VL3DIR=${VL3DIR:-${sdir}/..}
#echo "$NSMDIR"

echo "------------- Create nsm-system namespace ----------"
if [[ "${INSTALL_OP}" != "delete" ]]; then
  kubectl create ns nsm-system ${KCONF:+--kubeconfig $KCONF}
fi
echo "------------Installing NSM monitoring-----------"
#helm template ${NSMDIR}/deployments/helm/nsm-monitoring --namespace nsm-system --set monSvcType=NodePort --set org=${HUB},tag=${TAG} | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

helm template ${NSMDIR}/deployments/helm/crossconnect-monitor --namespace nsm-system --set insecure="true" --set global.JaegerTracing="true" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -
helm template ${NSMDIR}/deployments/helm/jaeger --namespace nsm-system --set insecure="true" --set global.JaegerTracing="true" --set monSvcType=NodePort | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -
helm template ${NSMDIR}/deployments/helm/skydive --namespace nsm-system --set insecure="true" --set global.JaegerTracing="true" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -


#kubednsip=$(kubectl get svc -n kube-system ${KCONF:+--kubeconfig $KCONF} | grep kube-dns | awk '{ print $3 }')
#kinddnsip=$(kubectl get svc ${KCONF:+--kubeconfig $KCONF} | grep kind-dns | awk '{ print $3 }')

echo "------------Installing NSM-----------"
helm template ${NSMDIR}/deployments/helm/nsm --namespace nsm-system --set org=${HUB},tag=${TAG} --set pullPolicy=Always --set insecure="true" --set global.JaegerTracing="true" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

echo "------------Installing NSM-addons -----------"
helm template ${VL3DIR}/helm/nsm-addons --namespace nsm-system --set global.NSRegistrySvc=true  | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

#helm template ${NSMDIR}/deployments/helm/nsm --namespace nsm-system --set global.JaegerTracing=true --set org=${HUB},tag=${TAG} --set pullPolicy=Always --set admission-webhook.org=tiswanso --set admission-webhook.tag=vl3-inter-domain2 --set admission-webhook.pullPolicy=Always --set admission-webhook.dnsServer=${kubednsip} ${kinddnsip:+--set "admission-webhook.dnsAltZones[0].zone=example.org" --set "admission-webhook.dnsAltZones[0].server=${kinddnsip}"} --set global.NSRegistrySvc=true --set global.NSMApiSvc=true --set global.NSMApiSvcPort=30501 --set global.NSMApiSvcAddr="0.0.0.0:30501" --set global.NSMApiSvcType=NodePort --set global.ExtraDnsServers="${kubednsip} ${kinddnsip}" --set global.OverrideNsmCoreDns="true" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -
#helm template ${NSMDIR}/deployments/helm/nsm --namespace nsm-system --set global.JaegerTracing=true --set org=${HUB},tag=${TAG} --set pullPolicy=Always --set admission-webhook.org=tiswanso --set admission-webhook.tag=vl3-inter-domain2 --set admission-webhook.pullPolicy=Always --set global.NSRegistrySvc=true --set global.NSMApiSvc=true --set global.NSMApiSvcPort=30501 --set global.NSMApiSvcAddr="0.0.0.0:30501" --set global.NSMApiSvcType=NodePort --set global.ExtraDnsServers="${kubednsip} ${kinddnsip}" --set global.OverrideDnsServers="${kubednsip} ${kinddnsip}" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

echo "------------Installing proxy NSM-----------"
helm template ${NSMDIR}/deployments/helm/proxy-nsmgr --namespace nsm-system --set org=${HUB},tag=${TAG} --set pullPolicy=Always --set insecure="true" --set global.JaegerTracing="true" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

#helm template ${NSMDIR}/deployments/helm/proxy-nsmgr --namespace nsm-system --set global.JaegerTracing=true --set org=${HUB},tag=${TAG} --set pullPolicy=Always --set global.NSMApiSvc=true --set global.NSMApiSvcPort=30501 --set global.NSMApiSvcAddr="0.0.0.0:30501" | kubectl ${INSTALL_OP} ${KCONF:+--kubeconfig $KCONF} -f -

#if [[ "${INSTALL_OP}" == "delete" ]]; then
#  echo "------------- Delete nsm-system ns ----------------"
#  kubectl delete ns nsm-system ${KCONF:+--kubeconfig $KCONF}
#fi
