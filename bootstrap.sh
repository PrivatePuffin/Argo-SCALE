#!/bin/bash


repo="https://github.com/truecharts/Argo-SCALE.git"
pool=tank
adminpassword=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)


zfs create ${pool}/argo
zfs create ${pool}/argo/pv
helm dependency update cluster-init/argoproj/argocd
helm dependency update cluster-init/argoproj/applicationset
helm upgrade --install argocd cluster-init/argoproj/argocd -n argocd --create-namespace --wait --timeout 120s
helm upgrade --install applicationset cluster-init/argoproj/applicationset -n argocd --wait --timeout 120s
k3s kubectl patch secret -n argocd argocd-secret -p '{"stringData": { "admin.password": "'$(htpasswd -bnBC 10 "" ${adminpassword} | tr -d ':\n')'"}}'

VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64
chmod +x /usr/local/bin/argocd

k3s kubectl port-forward svc/argocd-server -n argocd 8686:443 &

sleep 5s

yes | argocd login localhost:8686 --username admin --password ${adminpassword}  --insecure

argocd proj create cluster-critical -d *,* -s ${repo}
argocd proj allow-cluster-resource cluster-critical '*' '*'
argocd proj list

argocd app create cluster-critical \
    --dest-namespace argocd \
    --dest-server https://kubernetes.default.svc \
    --repo ${repo} \
    --path cluster-critical
argocd app sync cluster-critical
argocd app list

echo "default admin password is set to ${adminpassword}"

pgrep kubectl | xargs kill -9