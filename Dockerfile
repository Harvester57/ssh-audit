# syntax=docker/dockerfile:latest
FROM scratch AS files

# Copy ssh-audit code to temporary container
COPY ssh-audit.py /
COPY src/ /

FROM python:3-alpine@sha256:082c70eaaabc02e5b3ec6ffba6ef0bf90e2441bf4fcb68fbb897906c6bdf1e15 AS runtime

# Update the image to remediate any vulnerabilities.
RUN apk upgrade -U --no-cache -a -l

# Remove suid & sgid bits from all files.
RUN find / -xdev -perm /6000 -exec chmod ug-s {} \; 2> /dev/null || true    

# Copy the ssh-audit code from files container.
COPY --from=files / /

# Allow listening on 2222/tcp for client auditing.
EXPOSE 2222

# Drop root privileges.
USER nobody:nogroup

ENTRYPOINT ["python3", "/ssh-audit.py"]
