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
alias service='sudo service --status-all'
alias boot_log="sudo sed $'s/\^\[/\E/g;s/\[1G\[/\[27G\[/' /var/log/boot"
alias du='du -h --max-depth=1'
alias dusort='du -ah | sort -hr'
alias df='df -h'
alias sf='php app/console'
alias sfclear='rm -rf app/cache/* && sf cache:warmup'
alias sfdockerclear='rm -rf app/cache/* && docker-compose run --rm web php app/console cache:warmup'
alias rm='rm -I'
alias puli='set -f;puli';puli(){ command puli "$@";set +f;}	
alias composer='composer -vv'
alias phpunit="docker run --rm -ti -v $(pwd):/app phpunit/phpunit"
alias npm-exec='PATH=$(npm bin):$PATH'
alias atoum='vendor/atoum/atoum/bin/atoum'

# Docker aliases
alias meteor='docker run -it --rm -v "$(pwd)":/app danieldent/meteor meteor'
