CODE_DIR = chain

all: help

test: ## Test build binary
	chmod +x chain/build/release/bin/letheand
	chain/build/release/bin/letheand --log-level=4 --data-dir=data

release: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) release

static:
	$(MAKE) -C $(CODE_DIR) release-static -j20

clean: ## Compile Lethean Blockchain
	$(MAKE) -C $(CODE_DIR) clean && rm -rf public

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

i686-pc-linux-gnu: ## Linux executables
	$(MAKE) -C $(CODE_DIR) depends target=i686-pc-linux-gnu


docker-x86_64-unknown-linux-gnu: ## x86_64-unknown-linux-gnu
	docker build -o build/x86_64-unknown-linux-gnu --build-arg BUILD=x86_64-unknown-linux-gnu .

docker-i686-pc-linux-gnu: ## i686-pc-linux-gnu
	docker build -o build/i686-pc-linux-gnu --build-arg BUILD=i686-pc-linux-gnu .

docker-arm-linux-gnueabihf: ## arm-linux-gnueabihf
	docker build -o build/arm-linux-gnueabihf --build-arg BUILD=arm-linux-gnueabihf .

docker-aarch64-linux-gnu: ## aarch64-linux-gnu
	docker build -o build/aarch64-linux-gnu --build-arg BUILD=aarch64-linux-gnu  .

docker-x86_64-w64-mingw32: ## x86_64-w64-mingw32
	docker build -o build/x86_64-w64-mingw32 --build-arg BUILD=x86_64-w64-mingw32  .

docker-i686-w64-mingw32: ## i686-w64-mingw32
	docker build -o build/i686-w64-mingw32 --build-arg BUILD=i686-w64-mingw32  .

docker-riscv64-linux-gnu: ## riscv64-linux-gnu
	docker build -o build/riscv64-linux-gnu --build-arg BUILD=riscv64-linux-gnu  .

docker-x86_64-unknown-freebsd: ## x86_64-unknown-freebsd
	docker build -o build/x86_64-unknown-freebsd --build-arg BUILD=x86_64-unknown-freebsd  .

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36mmake %-30s\033[0m %s\n", $$1, $$2}'