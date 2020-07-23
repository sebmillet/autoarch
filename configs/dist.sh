#!/usr/bin/bash

# dist.sh

# Copyright 2020 Sébastien Millet, milletseb@laposte.net

set -euo pipefail

function process_entry {
    local f=$1
    local cfg=$2
    local myhome=$3

    t=$(readlink "${f}")

    cpopt=
    cppostpath=
    finalcpopt=
    if [ -d "${f}" ]; then
        cppostpath="/*"
        cpopt='-r'
        finalcpopt="${finalcpopt} -r"
    else
        cpopt='-L'
    fi

    sudoprefix="sudo "
    pre=
    tl=${t/$myhome\//}
    if [ "${tl}" != "${t}" ]; then
        t="${tl}"
            # shellcheck disable=SC2088
        pre="~/"
        sudoprefix=
    fi

    cfgtarget="${cfg}/"
    if [ -d "${f}" ]; then
        tmp=${f#./}
        cfgtarget="${cfg}/${tmp}/"
        mkdir -p "${cfgtarget}"
    fi
    shopt -s dotglob
        # shellcheck disable=SC2086
    ${sudoprefix} cp -v ${cpopt} "${f}"${cppostpath} "${cfgtarget}"
    shopt -u dotglob

    if [ "$(echo "${tl}" | grep -c "/")" -ne 0 ] && [ -z "${sudoprefix}" ]; then
        tle=${tl%/*}
        echo "mkdir -p "${pre}'"'"${tle}"'"' \
            >> "${cfg}/install.sh"
    fi

        # The below is done because a '-r' cp option will copy also source name
        # in destination. That is, when executing the 'install.sh' script, the
        # copy command was:
        #   cp -r ./.vim ~/.vim
        # and this was copying ./.vim underneath ~/.vim, resulting in an
        # auto-repeating structure ~/.vim/.vim
        # Therefore, when copying a directory, the target is simply ~/
    target="${pre}"'"'"${t}"'"'
    if [ -d "${f}" ]; then
        t_without_last_dir=${tl%/*}
        if [ "${tl}" == "${t_without_last_dir}" ]; then
            target="${pre}"
        else
            target="${pre}"'"'"${t_without_last_dir}"'"'
        fi
#        echo "========== [${t_without_last_dir}] =========="
    fi

    echo "${sudoprefix}cp --preserve=all \${delayed_cpopt} ${finalcpopt} "'"'"${f}"'"'" ${target}" \
        >> "${cfg}/install.sh"
}

mkdiropt=
if [ "${1:-}" == "-f" ]; then
    mkdiropt="-p"
    shift
fi

if [ -n "${1:-}" ]; then
    echo "Unknown option: ${1:-}"
    exit 1
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

userhome="/home/sebastien"

for II in 1 2; do
    echo
    echo "== TOUR ${II}"

    if [ "${II}" == "1" ]; then
        usercfg="cfg-seb-PRIVATE"
    else
        usercfg="cfg-seb-PUBLIC"
    fi

    mkdir ${mkdiropt} "${usercfg}"

    {
        echo "#!/usr/bin/bash"; \
        echo ""; \
        echo "set -euo pipefail"; \
        echo ""; \
        echo 'delayed_cpopt="${1:-}"'; \
        echo ""; \
    } > "${usercfg}/install.sh"
    chmod +x "${usercfg}/install.sh"

    # WARNING
    #   The code below contains tab characters, that must be kept as they are
    #   (they are part of Makefile recipe).
    {
        echo "default:"; \
        echo "	@echo "'"'"Run 'make install' to install config files"'"'; \
        echo "	exit 1"; \
        echo ""; \
        echo "install:"; \
        echo '	./install.sh $(cpopt)'; \
    } > "${usercfg}/Makefile"

    if [ "${II}" == "1" ]; then
        find . -type l | while read -r f; do
            process_entry "${f}" ${usercfg} ${userhome}
        done
    else
        for f in ./.abcde.conf ./.alacritty.yml.gnome ./.alacritty.yml.i3 \
          ./.aliases ./.conkyrc ./.conkyrc-i3 ./.gitconfig ./.gitignore \
          ./.perlcriticrc ./.perltidyrc ./.profile ./.prpn ./.tmux.conf ./.vim \
          ./.vimrc ./.zsh-extra ./.zshrc ./alacritty-config.desktop ./bin \
          ./calibre ./config ./conky.desktop ./dconf \
          ./ignore-lid-switch-tweak.desktop ./keepassxc ./system.cfg \
          ./user.cfg ./.gnuradio;
          do
            process_entry "${f}" ${usercfg} ${userhome}
        done
    fi

    tar -zcf "${usercfg}.tar.gz" "${usercfg}"
    rm -rf "${usercfg}"

    echo "== TOUR ${II}: file ${usercfg}.tar.gz created."
done

