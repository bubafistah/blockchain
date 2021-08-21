CODE_DIR = chain

all: help

test: ## Test build binary
	chmod +x chain/build/release/bin/letheand
	chain/build/release/bin/letheand --log-level=4

release: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) release

static:
	$(MAKE) -C $(CODE_DIR) release-static

clean: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) clean && rm -rf public

i686-linux-gnu: ## Compiles Linux 32 static executables
	$(MAKE) -C $(CODE_DIR) depends target=i686-linux-gnu

x86_64-linux-gnu: ## Compiles Linux 64 static executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-linux-gnu

i686-w64-mingw32: ## Compiles Windows 32 static executables
	$(MAKE) -C $(CODE_DIR) depends target=i686-w64-mingw32

x86_64-w64-mingw32: ## Compiles Windows 64 static executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-w64-mingw32

x86_64-apple-darwin11: ## MacOS Intel executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-apple-darwin11

arm-linux-gnueabihf: ## Arm7 32 executables
	$(MAKE) -C $(CODE_DIR) depends target=arm-linux-gnueabihf

aarch64-linux-gnu: ## Arm8 64 executables
	$(MAKE) -C $(CODE_DIR) depends target=aarch64-linux-gnu

riscv64-linux-gnu: ## RISC V64 executables
	$(MAKE) -C $(CODE_DIR) depends target=riscv64-linux-gnu

x86_64-unknown-freebsd: ## FreeBSD executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-unknown-freebsd

x86_64-unknown-linux-gnu: ## Linux executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-unknown-linux-gnu

arm-linux-android: ## Android 32 executables
	$(MAKE) -C $(CODE_DIR) depends target=arm-linux-android

aarch64-linux-android: ## Android 64 executables
	$(MAKE) -C $(CODE_DIR) depends target=aarch64-linux-android

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'