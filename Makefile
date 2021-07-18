.PHONY: help static release static clean linux-32 linux-64 windows-32 windows-64 test
.PHONY: macos-intel arm-7 arm-8 risc-v64 freebsd-64 android-32 android-64

CODE_DIR = chain

all: help

test: ## Compile Lethean Blockchain
	chmod +x chain/build/release/bin/letheand
	chain/build/release/bin/letheand --log-level=4

release: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) release

static:
	$(MAKE) -C $(CODE_DIR) release-static

clean: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) clean && rm -rf public

linux-32: ## Compiles Linux 32 static executables
	$(MAKE) -C $(CODE_DIR) depends target=i686-linux-gnu

linux-64: ## Compiles Linux 64 static executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-linux-gnu

windows-32: ## Compiles Windows 32 static executables
	$(MAKE) -C $(CODE_DIR) depends target=i686-w64-mingw32

windows-64: ## Compiles Windows 64 static executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-w64-mingw32

macos-intel: ## MacOS Intel executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-apple-darwin11

arm-7: ## Arm7 32 executables
	$(MAKE) -C $(CODE_DIR) depends target=arm-linux-gnueabihf

arm-8: ## Arm8 64 executables
	$(MAKE) -C $(CODE_DIR) depends target=aarch64-linux-gnu

risc-v64: ## RISC V64 executables
	$(MAKE) -C $(CODE_DIR) depends target=riscv64-linux-gnu

freebsd-64: ## FreeBSD executables
	$(MAKE) -C $(CODE_DIR) depends target=x86_64-unknown-freebsd

android-32: ## Android 32 executables
	$(MAKE) -C $(CODE_DIR) depends target=arm-linux-android

android-64: ## Android 64 executables
	$(MAKE) -C $(CODE_DIR) depends target=aarch64-linux-android

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'