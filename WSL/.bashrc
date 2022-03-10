# Symlinks
## Kubectl
ln -s ~/winhome/.kube ~

# Tools
## Kubectl
### https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/#bash
source <(kubectl completion bash)
alias k=kubectl
complete -F __start_kubectl k