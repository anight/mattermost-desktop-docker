
FROM opensuse/tumbleweed as mattermost-desktop-builder

RUN zypper -qn ref
RUN zypper -qn in gcc-c++ python2 git curl tar gzip npm10

RUN mkdir /build
ENV HOME=/build
WORKDIR ${HOME}

RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH="${HOME}/.yarn/bin:${HOME}/.config/yarn/global/node_modules/.bin:${PATH}"

RUN git clone https://github.com/mattermost/desktop mattermost-desktop
WORKDIR /build/mattermost-desktop

RUN yarn
RUN npm run build
RUN npm run package:linux

FROM opensuse/tumbleweed

RUN zypper -qn ref
RUN zypper -qn in libgtk-3-0 libX11-xcb1 libXss1 gconf2 mozilla-nss libasound2 Mesa-libGL1

COPY --from=mattermost-desktop-builder /build/mattermost-desktop/release/linux-unpacked /opt/mattermost-desktop

ENV PATH="/opt/mattermost-desktop:${PATH}"

ARG user="n/a"
ARG group="n/a"
ARG uid="n/a"
ARG video_gid="n/a"
ARG audio_gid="n/a"

RUN groupmod -g ${video_gid} video
RUN groupmod -g ${audio_gid} audio
RUN useradd -m -u ${uid} -g ${group} -G video,audio ${user}

USER ${user}
ENV HOME /home/${user}

ENTRYPOINT ["mattermost-desktop"]

