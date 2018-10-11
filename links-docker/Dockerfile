FROM ocaml/opam2:alpine-3.8-ocaml-4.06
WORKDIR /home/opam
ADD links links
ADD opam-repository opam-repository-snapshot
USER root
WORKDIR /root
RUN apk update && apk upgrade && \
	apk add coreutils && \
	apk add camlp4 m4 libressl-dev && \
	chown opam:nogroup -R /home/opam/links
USER opam
WORKDIR /home/opam/links
RUN \
  opam upgrade && \
  opam repository set-url default /home/opam/opam-repository-snapshot && \
  opam update && opam upgrade && \
  opam install -y dune
RUN	eval `opam config env` && \
	opam pin add links . -y && \
  opam pin add links-postgresql . -y && \
	make nc && \
	sudo ln -s /home/opam/links/linx /usr/local/bin/
RUN eval `opam config env` && \
	opam pin add links . -y
WORKDIR /home/opam/
EXPOSE 8080
CMD [ "bash" ]
