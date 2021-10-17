#compdef cdg

function _cdg() {
    compadd -S '' $(cd ~/git && ls -d ${words[2]}*/)
}
