# .bash_aliases

alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls --color=always -F --group-directories-first'
alias ll='ls -lahF'
alias lo="ls -lha --color=always -F --group-directories-first | awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\"%0o \",k);print}'"
alias vi='vim'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias ping='ping -c 5'
alias power_now='cat /sys/class/power_supply/BAT0/power_now'
alias service='sudo service --status-all'
alias gpu_statut='cat /proc/acpi/bbswitch'
alias switch_gpu_off='sudo tee /proc/acpi/bbswitch <<<OFF'
alias switch_gpu_on='sudo tee /proc/acpi/bbswitch <<<ON'
alias boot_log="sudo sed $'s/\^\[/\E/g;s/\[1G\[/\[27G\[/' /var/log/boot"
alias skype_correct="LD_PRELOAD=/usr/lib/i386-linux-gnu/libv4l/v4l1compat.so nohup skype&"
alias du='du -h --max-depth=1'
alias dusort='du -x --block-size=1048576 | sort -nr'
alias df='df -h'
alias ap="apt-get update && apt-get upgrade && apt-get dist-upgrade && apt-get autoclean && apt-get clean && apt-get autoremove && debclean"

