FROM clfoundation/sbcl:2.2.4 AS build

WORKDIR /home

RUN apt-get update \
    && apt-get install -y libmagic-dev libc6-dev gcc wget git make cl-quicklisp

COPY src ./src
COPY scripts ./scripts
COPY CIEL ./CIEL

# install CIEL dependencies
RUN mkdir -p ~/common-lisp \
    && ( cd ~/common-lisp/ && wget https://asdf.common-lisp.dev/archives/asdf-3.3.5.tar.gz  && tar -xvf asdf-3.3.5.tar.gz && mv asdf-3.3.5 asdf )
RUN sbcl --noinform --non-interactive --load scripts/install_quicklisp.lisp --eval '(ql-util:without-prompting (ql:add-to-init-file))'

RUN cd ./CIEL \
    && make ql-deps \
    && make build

FROM scratch AS binaries

COPY --from=build /home/CIEL/bin/ciel /bin/ciel
COPY --from=build /home/CIEL/bin/libmagic.so.1.0.0 /bin/
COPY --from=build /home/CIEL/bin/libosicat.so /bin/
COPY --from=build /home/CIEL/bin/libreadline.so.8.1 /bin/
COPY --from=build /home/CIEL/bin/librt-2.31.so /bin/
COPY --from=build /home/CIEL/bin/libz.so.1.2.11 /bin/

FROM clfoundation/sbcl:2.2.4 AS run

COPY --from=build /home/src /src/
COPY --from=binaries /bin /

ENTRYPOINT [ "/ciel", "/src/app.lisp" ]
