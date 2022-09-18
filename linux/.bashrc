# /etc/skel/.bashrc
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi

# Aliases
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ls='ls --color=auto'
alias ll='ls -l'
alias capture='ffmpeg -video_size 1920x1200 -framerate 25 -f x11grab -i :0.0 -f pulse -ac 2 -i default ~/Video/capture-$(date +%Y%m%d_%H%M%S).mkv'

# History
export HISTTIMEFORMAT="%F %H:%M:%S "
export HISTSIZE=
export HISTCONTROL="ignoredups"
export HISTIGNORE=" cd *:  PROMPT_COMMAND=*"

# Env
export EDITOR=vim

# Prompt
PS1='\[\e[0;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w $\[\e[m\] '

# Bash Completion
SSH_COMPLETE=( $(cut -f1 -d' ' ~/.ssh/known_hosts|tr ',' '\n'|sort -u |grep -e '[[:alpha:]]'|awk '{print $1}'|awk -F ']' '{print $1}'|sed 's/\[//g'))
complete -o default -W "${SSH_COMPLETE[*]}" ssh
complete -o default -W "${SSH_COMPLETE[*]}" ping
complete -o default -W "${SSH_COMPLETE[*]}" drill

# Functions
gen_random_password() { LC_CTYPE=C tr -dc A-FHK-NP-Za-fhikm-z1-9_.- < /dev/urandom | head -c 24 | xargs; }
gen_htaccess() { echo -n "Username: "; read username; printf "${username}:`openssl passwd -apr1`\n"; }
gen_self_signed_certificate() { openssl req -new -sha1 -newkey rsa:4096 -days 731 -nodes -x509 -keyout "${1}.key" -out "${1}.crt"; }
crt_decode() { for i in $@; do openssl x509 -in "$i" -text -noout; done; }
csr_decode() { for i in $@; do openssl req -in "$i" -noout -text; done; }
low_priority() { ionice -c3 nice -19 bash; }

# Run
gen_random_password
