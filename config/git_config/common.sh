git config --global user.name "Ondrej Filip"
git config --global push.default simple

git config --global diff.tool meld
git config --global difftool.meld.cmd "meld \"\$LOCAL\" \"\$REMOTE\""
git config --global difftool.prompt false

git config --global merge.tool meld
git config --global mergetool.meld.cmd "meld \"\$LOCAL\" \"\$BASE\" \"\$REMOTE\""
