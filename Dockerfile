FROM jenkins/inbound-agent:latest

USER root

# Clear the apt cache
RUN rm -rf /var/lib/apt/lists/*

# Install required packages in a single RUN statement with error handling
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    gnupg \
    lsb-release \
    jq \
    curl \
    unzip \
    apt-transport-https \
    ca-certificates \
    software-properties-common \
    sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Allow jenkins user to use sudo without a password
RUN echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Docker using the official script
RUN curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    usermod -aG docker jenkins

# Download HashiCorp GPG key and add it to keyrings
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository to sources list
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# Download 1Password GPG key and add it to keyrings
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

# Add 1Password repository to sources list
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
    tee /etc/apt/sources.list.d/1password.list

# Configure debsig policies for 1Password
RUN mkdir -p /etc/debsig/policies/AC2D62742012EA22/ && \
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
    tee /etc/debsig/policies/AC2D62742012EA22/1password.pol && \
    mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22 && \
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
    gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

# Install 1Password CLI
RUN apt-get update && \
    apt-get install -y 1password-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl by downloading the binary
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install kubectl /usr/local/bin/kubectl

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws

# Add jenkins user to docker group
RUN usermod -aG docker jenkins

# Copy entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Change permissions of entrypoint script
RUN chmod +x /usr/local/bin/entrypoint.sh

USER jenkins

# Set the working directory
WORKDIR /home/jenkins/agent

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["jenkins-agent"]

