FROM quay.io/fedora/fedora:32-x86_64

RUN dnf install --setopt=tsflags=nodocs -y \
    iproute bind-utils iputils keepalived && \
    dnf clean all && \
    rm -rf /var/cache/dnf

LABEL   io.k8s.display-name="OCP VIP" \
        io.k8s.description="OCP VIP functionality" \
        io.openshift.tags="ocp-vip"

ADD ./Scripts/entrypoint.sh /

ENTRYPOINT /bin/bash -c "sleep infinity"