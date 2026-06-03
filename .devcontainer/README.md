# Grails 7 Development Container

This repository contains a fully containerized, IDE-agnostic development environment tailored for building **Grails 7** applications. It adheres to the official Development Container Specification, allowing you to launch an identical environment using **Visual Studio Code** or **IntelliJ IDEA**.

---

## 🚀 Key Features

- **Java 17 Baseline:** Configured to use Microsoft OpenJDK 17 (`/usr/lib/jvm/msopenjdk-current`).
- **Dual IDE Optimization:** Includes dedicated configurations, settings, and first-class plugins for both VS Code and IntelliJ IDEA.
- **Docker-outside-of-Docker (DooD):** Seamless support for running Docker commands directly from inside your workspace (essential for building container images or spinning up external services).
- **Testcontainers Ready:** Configured to automatically route internal Testcontainers infrastructure back to the host machine's Docker daemon.
- **Persistent Caching:** Named Docker volumes cache your Gradle distributions, project dependencies, and IntelliJ project indexes so they survive container restarts and rebuilds.

---

## 🛠️ Environment Variables Configuration

The environment is preset with the following runtime optimizations via `remoteEnv`:

| Variable                       | Value                             | Purpose                                                                                                                    |
| :----------------------------- | :-------------------------------- | :------------------------------------------------------------------------------------------------------------------------- |
| `GRADLE_OPTS`                  | `-Dfile.encoding=UTF-8 -Xmx1024M` | Ensures consistent encoding formatting and prevents memory exhaustion out-of-the-box.                                      |
| `TESTCONTAINERS_HOST_OVERRIDE` | `host.docker.internal`            | Routes Testcontainers-spawned internal daemons correctly to the host machine.                                              |
| `TESTCONTAINERS_RYUK_DISABLED` | `true`                            | Streamlines container lifecycle mapping across the DooD bridge by bypassing the standard Moby cleanup companion container. |

## 🔒 Secrets & Local Configuration (.env)

To keep sensitive data (like database passwords, API tokens, or encryption keys) out of source control, this project utilizes Docker's `--env-file` flag via the `"runArgs"` parameter in `devcontainer.json`.

This injects variables from your local machine directly into the container's environment at runtime, making them accessible to your Grails application via standard environment lookups (e.g., `System.getenv("DB_PASSWORD")`).

### Setup Instructions

Because the environment file contains secrets, it is explicitly blocked by `.gitignore` and will never be committed to Git. Follow these steps to configure your local environment:

1. Navigate to the `.devcontainer/` directory.
2. Create a copy of the template file and name it `devcontainer.env`:
   ```bash
   cp .devcontainer/devcontainer.env.example .devcontainer/devcontainer.env
   ```

---

## 📂 Named Volume Mounts & Permissions

To maintain high performance, the container uses named Docker volumes mapped inside the `vscode` user's home directory:

1. **`gradle-cache`** $\rightarrow$ `/home/vscode/.gradle`
   _Saves compiled artifacts and dependency `.jar` files so initial setup times don't repeat._
2. **`intellij-cache`** $\rightarrow$ `/home/vscode/.cache/JetBrains`
   _Retains IDE code index histories to prevent IntelliJ from pegging your CPU with re-indexing tasks every time the container spins up._

> 💡 **Permission Management:** Docker maps newly provisioned named volumes to the `root` user by default. This environment includes an automated lifecycle hook (`postCreateCommand`) that seamlessly handles permissions behind the scenes:
>
> ```bash
> sudo chown -R vscode:vscode /home/vscode/.gradle /home/vscode/.cache
> ```

---

## 🔌 IDE Customizations

### Visual Studio Code

Opening this project installs the following extensions automatically:

- **Extension Pack for Java** (`vscjava.vscode-java-pack`)
- **Gradle for Java** (`vscjava.vscode-gradle`)
- **Groovy Language Support** (`marlon407.code-groovy`)
- **Spring Boot Tools** (`vmware.vscode-spring-boot`)
- **XML Tools** (`redhat.vscode-xml`)

_Note: Workspace settings pre-configure the Java tooling engine (`java.import.gradle.java.home`) to lock onto `/usr/lib/jvm/msopenjdk-current`._

### IntelliJ IDEA (via JetBrains Gateway)

Launching via IntelliJ instruments a headless backend with preloaded plugins:

- **Groovy** (`org.intellij.groovy`)
- **Grails Framework** (`com.jetbrains.plugins.grails`)
- **Gradle Support** (`com.intellij.gradle`)

---

## 🏁 Getting Started

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running on your machine.
- **For VS Code:** Install the [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).
- **For IntelliJ IDEA:** Install the [Dev Containers Plugin](https://plugins.jetbrains.com/plugin/21510-dev-containers).

### How to Launch

#### Option A: Visual Studio Code

1. Open your project root folder in VS Code.
2. Copy `devcontainer.env.example` to `devcontainer.env`.
3. Open `devcontainer.env` then paste the APP_DB_PASSWORD value.
4. A prompt should appear in the lower-right corner asking to reopen the folder in a container. Click **Reopen in Container**.
5. If the prompt does not appear, open the Command Palette (`Cmd+Shift+P` on Mac / `Ctrl+Shift+P` on Windows) and select `Dev Containers: Reopen in Container`.

#### Option B: IntelliJ IDEA

1. Open the project folder in IntelliJ IDEA.
2. Ensure your local Docker daemon connection is greenlit in your IDE preferences.
3. Right-click on the `.devcontainer/devcontainer.json` file and select **Create Dev Container** or choose the option from your IDE toolbar prompt.

---

## 🌐 Port Mappings

The configuration automatically exposes and assigns labels to the following network ports:

- **Port `8080` (Grails App):** Forwards web application traffic with an explicit system notification on startup.
- **Port `5005` (JVM Debug):** Forwards remote debugging channels silently for seamless step-through diagnostics.
  README.md
  Displaying README.md.
