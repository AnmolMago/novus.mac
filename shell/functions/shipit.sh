# Commit with message

function shipit() {
  if [ -z "$1" ]; then
    echo "Please provide path for files"
    return
  fi
  if [ -z "$2" ]; then
    echo "Please provide commit msg"
    return
  fi
  git add "$1";
  eval "git commit -m \"${@:2}\"";
  git push;
}