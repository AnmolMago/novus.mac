# Commit with message

function shipit() {
  to_add="."
  commit_msg="update"
  if [[ -n "$1" ]]; then
    to_add=$1
  fi
  if [ -n "$2" ]; then
    commit_msg=${@:2}
  fi
  echoeval git add "${to_add}";
  echoeval "git commit -m \"${commit_msg}\"";
  echoeval git push;
}
