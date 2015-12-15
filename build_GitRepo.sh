#!/bin/bash

# -----------------------------------------------------
# build_GitRepo.sh (DD | 151128)
# -----------------------------------------------------
# 
# résumé: initialisation d'un repo Git local et clonage sur GitHub
# prérequis:
#	-avoir créé un compte <REMOTE_USER> sur GitHub (https://github.com)
#	-avoir généré un couple de clefs ssh (privée, publique) en local
#	-avoir déposé la clef publique sur GitHub
#


# -----------------------------------------------------
# fonctions
# -----------------------------------------------------

function Usage()
{
  echo "utilisation: $(basename $0) <nom de projet>"
  echo "	le paramètre <nom de projet> est obligatoire!"
  exit 1
}

function CheckSshAgent()
{
# vérifie si un agent ssh tourne...
ps -ef | grep -v "grep" | grep "ssh-agent -s"
if [ $? -eq 1 ]
then
# dans la négative on le lance...
  eval "$(ssh-agent -s)"
  ssh-add ~$LOCAL_USER/.ssh/id_rsa
fi
}

function CheckGitHub()
{
# test de connexion à GitHub...
ssh -T git@github.com
}

function BuildLocalRepo()
{
# création du repo local...
if [ ! -d $LOCAL_WD/$REPO ]
then
  echo "création du repo local $REPO..."
  mkdir $LOCAL_WD/$REPO
  cd $LOCAL_WD/$REPO
  cat > $LOCAL_WD/$REPO/README.md << !EOF
# Projet: $REPO
# Date création: $(date)
# par: $LOCAL_USER
# informations système local:
# $LOCAL_SYSTEM
# version GIT local: $(git --version | awk '{print $3}')
!EOF
  git init
  cd $LOCAL_WD
fi
}

function BuildRemoteRepo()
{
# création du repo distant sur GitHub...
CURLCMD="curl -u $REMOTE_USER https://api.github.com/user/repos -d '{\"name\":\"$REPO\"}'"
eval $CURLCMD 2>&1 > $LOCAL_WD/$REPO/init.log
}

function FirstCommit()
{
# premier commit...
MESSAGE="initialisation $REPO; ajout README.md"
echo $MESSAGE
cd $LOCAL_WD/$REPO
git add README.md
git commit -m "$MESSAGE"
git remote add origin git@github.com:$REMOTE_USER/${REPO}.git
git push -u origin master
}


# -----------------------------------------------------
# variables
# -----------------------------------------------------

LOCAL_USER=$(whoami)
LOCAL_WD=$(pwd)
LOCAL_SYSTEM=$(uname -a)
# REMOTE_USER doit etre positionné au nom
# d'utilisateur sur GitHub
REMOTE_USER=dd31530


# -----------------------------------------------------
# main
# -----------------------------------------------------

[ $# -eq 0 ] && Usage
REPO=$1
CheckSshAgent
CheckGitHub
BuildLocalRepo
BuildRemoteRepo
FirstCommit

# eof
