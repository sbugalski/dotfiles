source /etc/bash_completion.d/azure-cli
complete -C /usr/local/bin/terraform terraform
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k

ln -s /mnt/c/Users/${USER}/.kube/ ~/.kube -f