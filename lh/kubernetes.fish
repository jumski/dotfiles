#/home/gajewsky/.dotfiles/fish/aliases.fish (lines 31-82)
function k-kibana
  kubectx lh_production
  kubectl -n monitoring port-forward svc/kibana-kibana 5601:5601 &
  sleep 2
  open http://localhost:5601
end

function k-fzf-running-pod
  set current_context (kubectx --current)
  set PROMPT "Pods on $current_context > "
  set service_name (basename $PWD)
  kubectl get pods | grep Running | awk '{ print $1 }' 2> /dev/null | fzf +m --prompt $PROMPT --query $service_name
end
function k-fzf-pod
  set current_context (kubectx --current)
  set PROMPT "Pods on $current_context > "
  set service_name (basename $PWD)
  kubectl get pods | awk '{ print $1 }' 2> /dev/null | fzf +m --prompt $PROMPT --query $service_name
end

function kexec
  set pod (k-fzf-running-pod)

  kubectl exec $pod -it -- $argv
end

# Example usage:
# kexec bash
# kexec bin/maintenance cli
# function kexec
#   set PROMPT "Select pod to execute \"$argv\" (current context: `kubectl config current-context`): "
#   set -l pod
#   set pod (k-fzf-running-pod) &&
#   kubectl exec -it $pod -- $argv
# end

# Print the pod's logs (requires fzf being installed)
function klogs
  set -l pod
  set pod (k-fzf-pod) &&
  kubectl logs -f $pod
end

function kdesc
  kubectl get po | fzf --header-lines=1 --multi --preview 'kubectl describe po {+1}' --bind 'ctrl-r:reload(kubectl get po)' --header 'Press CTRL-R to reload'
end
